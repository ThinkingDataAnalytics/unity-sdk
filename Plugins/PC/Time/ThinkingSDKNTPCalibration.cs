using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net;
using System.Net.Sockets;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Utils;
using System.Linq;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKNTPCalibration : ThinkingSDKTimeCalibration
    {
        public ThinkingSDKNTPCalibration(string ntpServer) {
            DateTime dateTimeUtcNow = DateTime.UtcNow;
            DateTime ntpTime = GetNetworkTime(ntpServer);
            double totalMilliseconds = ConvertDateTimeInt(ntpTime);

            this.mStartTime = (long)totalMilliseconds;
            this.mSystemElapsedRealtime = Environment.TickCount;

			double time_offset = (ConvertDateTimeInt(dateTimeUtcNow) - totalMilliseconds) / 1000;
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Time Calibration with NTP (" + ntpServer + "), diff = " + time_offset.ToString("0.000s"));
        }

		private static DateTime GetNetworkTime(string ntpServer)
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
			
			//Stops code hang if NTP is blocked
			socket.ReceiveTimeout = 3000;
			
			socket.Send(ntpData);
			socket.Receive(ntpData);
			socket.Close();
			
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
			
			// return networkDateTime.ToLocalTime();
			return networkDateTime;
		}
		
		static uint SwapEndianness(ulong x)
		{
			return (uint)(((x & 0x000000ff) << 24) + ((x & 0x0000ff00) << 8) + ((x & 0x00ff0000) >> 8) + ((x & 0xff000000) >> 24));
		}
    }

    
}