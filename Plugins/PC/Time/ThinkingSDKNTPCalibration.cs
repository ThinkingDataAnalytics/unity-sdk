using System;
using System.Net;
using System.Net.Sockets;
using System.Linq;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKNTPCalibration : ThinkingSDKTimeCalibration
    {
        public ThinkingSDKNTPCalibration(string ntpServer) {
            double totalMilliseconds = ConvertDateTimeInt(DateTime.UtcNow);
            this.mStartTime = (long)totalMilliseconds;
            this.mSystemElapsedRealtime = Environment.TickCount;

            // request scoket time
            Socket socket = GetNetworkTimeSync(ntpServer, this);
            // set scoket timeout
            TDTimeout.SetTimeout(3, new Action<object>(ScoketTimeout), (object)socket);
        }

        private void ScoketTimeout(object obj)
        {
            if (obj is Socket)
            {
                Socket socket = (Socket)obj;
                if (socket.Connected == true)
                {
                    socket.Close();
                }
            }
        }

        protected static new double ConvertDateTimeInt(System.DateTime time)
        {
            DateTime startTime = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
 		    return (double)(time - startTime).TotalMilliseconds;
 		}

        private static Socket GetNetworkTimeSync(string ntpServer, ThinkingSDKTimeCalibration timeCalibration)
        {
            // NTP message size - 16 bytes of the digest (RFC 2030)
            var ntpData = new byte[48];

            //Setting the Leap Indicator, Version Number and Mode values
            ntpData[0] = 0x1B; //LI = 0 (no warning), VN = 3 (IPv4 only), Mode = 3 (Client Mode)

            var addresses = Dns.GetHostEntry(ntpServer).AddressList;
            var addressFirst = addresses.First(e => e.AddressFamily == AddressFamily.InterNetwork);
            if (addressFirst == null)
            {
                addressFirst = addresses[0];
            }

            //The UDP port number assigned to NTP is 123
            var ipEndPoint = new IPEndPoint(addressFirst, 123);
            //NTP uses UDP
            var socket = new Socket(ipEndPoint.AddressFamily, SocketType.Dgram, ProtocolType.Udp);

            socket.Connect(ipEndPoint);

            SocketAsyncEventArgs socketAsyncEventArgs = new SocketAsyncEventArgs();
            socketAsyncEventArgs.SetBuffer(ntpData, 0, ntpData.Length);
            socketAsyncEventArgs.UserToken = timeCalibration;
            socketAsyncEventArgs.RemoteEndPoint = ipEndPoint;
            socketAsyncEventArgs.Completed += SocketAsyncEventArgs_Completed;
            // send socket request
            socket.SendAsync(socketAsyncEventArgs);

            return socket;
        }

        private static void SocketAsyncEventArgs_Completed(object sender, SocketAsyncEventArgs eventArgs)
        {
            Socket socket = (Socket)sender;
            if (eventArgs.SocketError == SocketError.Success)
            {
                if (eventArgs.LastOperation == SocketAsyncOperation.Send)
                {
                    socket.ReceiveAsync(eventArgs);
                }
                else if (eventArgs.LastOperation == SocketAsyncOperation.Receive)
                {
                    if (eventArgs.SocketError == SocketError.Success && eventArgs.Buffer.Length > 0)
                    {
                        DateTime ntpTime = ParseDateTimeWithNTPData(eventArgs.Buffer);
                        double totalMilliseconds = ConvertDateTimeInt(ntpTime);
                        ThinkingSDKTimeCalibration timeCalibration = (ThinkingSDKTimeCalibration)eventArgs.UserToken;
                        timeCalibration.mStartTime = (long)totalMilliseconds;
                    }
                    socket.Close();
                }
                else
                {
                    socket.Close();
                }
            }
            else
            {
                socket.Close();
            }
        }

        static uint SwapEndianness(ulong x)
		{
			return (uint)(((x & 0x000000ff) << 24) + ((x & 0x0000ff00) << 8) + ((x & 0x00ff0000) >> 8) + ((x & 0xff000000) >> 24));
		}

        private static DateTime ParseDateTimeWithNTPData(byte[] ntpData)
        {
            //Offset to get to the "Transmit Timestamp" field (time at which the reply 
            //departed the server for the client, in 64-bit timestamp format."
            const byte serverReplyTime = 40;

            //Get the seconds part
            ulong intPart = BitConverter.ToUInt32(ntpData, serverReplyTime);

            //Get the seconds fraction
            ulong fractPart = BitConverter.ToUInt32(ntpData, serverReplyTime + 4);

            //Convert From big-endian to little-endian
            intPart = SwapEndianness(intPart);
            fractPart = SwapEndianness(fractPart);

            var milliseconds = (intPart * 1000) + ((fractPart * 1000) / 0x100000000L);

            //**UTC** time
            var networkDateTime = (new DateTime(1900, 1, 1, 0, 0, 0, DateTimeKind.Utc)).AddMilliseconds((long)milliseconds);
            return networkDateTime;
        }
    }
}