## Unity SDK 使用指南

本指南将会介绍如何使用 Unity SDK 接入您的项目。

#### 1. 初始化 SDK
1.1 下载 [Unity SDK ](https://thinkingdata.cn/thinkingdata.package)资源文件，并导入资源文件到您的项目中：Assets>Import Package > Custom Package，选中您刚刚下载的文件

1.2 添加 ThinkingAnalytics GameObject, 并配置服务器地址和 APP ID

<img src="https://doc.thinkingdata.cn/tdamanual/assets/unity_sdk_installation_1.png" width = "50%"/>

>    注意：Android 插件使用 Gradle 集成，因此目前只支持 Unity 5.4 之后的版本。 

1.3 使用 SDK

当您配置好服务器地址和 APP ID 后，就可以开始使用 ThinkingAnalytics namespace 上传事件了，我们也提供了 Sample 供您参考。

```
using ThinkingAnalytics;

ThinkingAnalyticsAPI.Track("unity_start");
```

#### 2 设置用户 ID
在使用TDA的SDK之后，SDK会使用UUID作为每个用户的默认访客ID，该ID将会作为用户在未登录状态下身份识别ID。需要注意的是，UUID在用户重新安装APP以及更换设备时将会变更。

2.1 设置访客 ID（可选）

如果您的 APP 对每个用户有自己的访客ID管理体系，则您可以调用`Identify`来设置访客 ID:
```
ThinkingAnalyticsAPI.Identify("unity_id");
```

如果需要获得访客 ID，可以调用`GetDistinctId`获取：
```
ThinkingAnalyticsAPI.GetDistinctId();
```

2.2 设置账号 ID

在用户进行登录时，可调用`Login`来设置用户的账号 ID，在设置完账号 ID 后，将会以账号 ID 作为身份识别 ID，并且设置的账号 ID 将会在调用`Logout`之前一直保留：
```
// 设置账号 ID
ThinkingAnalyticsAPI.Login("unity_user");

// 清除账号 ID
ThinkingAnalyticsAPI.Logout();
```
> 注意：该方法不会上传用户登录、用户登出等事件。

#### 3 上传事件
通过`ThinkingAnalyticsAPI.Track()` 可以记录事件及其属性。一般情况下，您可能需要上传十几到上百个不同的事件，如果您是第一次使用 TDA 后台，我们推荐您先上传几个关键事件。

3.1 上传事件

建议您根据先前梳理的文档来设置事件的属性以及发送信息的条件。事件名称是`string`类型，只能以字母开头，可包含数字，字母和下划线“_”，长度最大为50个字符，对字母大小写不敏感。
- 事件属性是`Dictionary<string, object>` 类型，其中每个元素代表一个属性；
- 事件属性`Key`为属性名称，为`string`类型，规定只能以字母开头，包含数字，字母和下划线“_”，长度最大为50个字符，对字母大小写不敏感；
- 属性值支持四种类型：字符串、数值类、bool、DateTime。

```
Dictionary<string, object> properties = new Dictionary<string, object>()
    {
        {"KEY_DateTime", DateTime.Now.AddDays(1)},
        {"KEY_STRING", "B1"},
        {"KEY_BOOL", true},
        {"KEY_NUMBER", 50.65}
    };
ThinkingAnalyticsAPI.Track("TEST_EVENT", properties);
```

当您调用 `Track()` 时，SDK 会取系统当前时间作为 `#event_time` 属性值，如果您需要指定事件时间，可以传入 `DateTime`:
```
DateTime dateTime = DateTime.Now.AddDays(-1);
ThinkingAnalyticsAPI.Track("TEST_EVENT", properties, dateTime);
```

> 注意：尽管事件可以设置触发时间，但是接收端会做如下的限制：只接收相对服务器时间在前 10 天至后 4 天的数据，超过时限的数据将会被视为异常数据，整条数据无法入库。

3.2 设置公共属性

对于一些重要的属性，譬如用户的会员等级、来源渠道等，这些属性需要设置在每个事件中，此时您可以将这些属性设置为公共事件属性。公共事件属性指的就是每个事件都会带有的属性，您可以调用`SetSuperProperties`来设置公共事件属性，我们推荐您在发送事件前，先设置公共事件属性。

```
Dictionary<string, object> superProperties = new Dictionary<string, object>()
    {
        {"SUPER_LEVEL", 0},
        {"SUPER_CHANNEL", "A3"}
    };
ThinkingAnalyticsAPI.SetSuperProperties(superProperties);
```
公共事件属性将会被保存到缓存中，无需每次启动`APP`时调用。如果调用`SetSuperProperties`上传了先前已设置过的公共事件属性，则会覆盖之前的属性。如果公共事件属性和`Track()`上传的某个属性的`Key`重复，则该事件的属性会覆盖公共事件属性。

如果您需要删除某个公共事件属性，您可以调用`UnsetSuperProperty()`清除其中一个公共事件属性；如果您想要清空所有公共事件属性，则可以调用`ClearSuperProperties()`.

```
// 清除属性名为 SUPER_CHANNEL 的公共属性
ThinkingAnalyticsAPI.UnsetSuperProperty("SUPER_CHANNEL");

// 清空所有公共属性
ThinkingAnalyticsAPI.ClearSuperProperties();
```

如果公共属性的值不是常量，您可以通过设置动态公共属性的方式实现。动态公共属性的优先级大于公共事件属性。设置动态公共属性需要实现 IDynamicSuperProperties 接口。方式如下：
```
using ThinkingAnalytics;

// 定义动态公共属性实现，此例为设置 UTC 时间的动态公共属性
public class DynamicProp : IDynamicSuperProperties
{
    public Dictionary<string, object> GetDynamicSuperProperties()
    {
        return new Dictionary<string, object>() {
            {"KEY_UTCTime", DateTime.UtcNow}
        };
    }
}

ThinkingAnalyticsAPI.SetDynamicSuperProperties(new DynamicProp());
```

3.3 记录事件时长

您可以调用`TimeEvent()`来开始计时，配置您想要计时的事件名称，当您上传该事件时，将会自动在您的事件属性中加入`#duration`这一属性来表示记录的时长，单位为秒。
```
// 调用 TimeEvent 开启对 TIME_EVENT 事件的计时
ThinkingAnalyticsAPI.TimeEvent("TIME_EVENT");

// do some thing...

// 通过 Track 上传 TIME_EVENT 事件时，会在属性中添加 #duration 属性
ThinkingAnalyticsAPI.Track("TIME_EVENT");
```

#### 4 用户属性
TDA 平台目前支持的用户属性设置接口为`UserSet`、`UserSetOnce`、`UserAdd`、`UserDelete`。

4.1 UserSet

对于一般的用户属性，您可以调用`UserSet`来进行设置，使用该接口上传的属性将会覆盖原有的属性值，如果之前不存在该用户属性，则会新建该用户属性。
```
ThinkingAnalyticsAPI.UserSet(new Dictionary<string, object>()
    {
        {"USER_PROP_NUM", 0},
        {"USER_PROP_STRING", "A3"}
    });
```
与事件属性类似：
- 用户属性是`Dictionary<string, object>` 类型，其中每个元素代表一个属性；
- 用户属性`Key`为属性名称，为`string`类型，规定只能以字母开头，包含数字，字母和下划线“_”，长度最大为50个字符，对字母大小写不敏感；
- 用户属性值支持四种类型：字符串、数值类、bool、DateTime。

4.2 UserSetOnce

如果您要上传的用户属性只要设置一次，则可以调用`UserSetOnce`来进行设置，当该属性之前已经有值的时候，将会忽略这条信息：
```
ThinkingAnalyticsAPI.UserSetOnce(new Dictionary<string, object>()
    {
        {"USER_PROP_NUM", -50},
        {"USER_PROP_STRING", "A3"}
    });
```
> 注意：`UserSetOnce`设置的用户属性类型及限制条件与`UserSet`一致。

4.3 UserAdd

当您要上传数值型的属性时，您可以调用`UserAdd`来对该属性进行累加操作，如果该属性还未被设置，则会赋值`0`后再进行计算，可传入负值，等同于相减操作。
```
ThinkingAnalyticsAPI.UserAdd(new Dictionary<string, object>()
    {
        {"USER_PROP_NUM", -100.9},
        {"USER_PROP_NUM2", 10.0}
    });
```
> 注意： `UserAdd` 置的属性类型以及`Key`值的限制与`UserSet`一致，但`Value`只允许数值类型。

4.4 UserDelete

如果您要删除某个用户，可以调用`UserDelete`将这名用户删除，您将无法再查询该名用户的用户属性，但该用户产生的事件仍然可以被查询到。
```
ThinkingAnalyticsAPI.UserDelete();
```

#### 5 自动采集事件
如果在配置 SDK 时，勾选了Auto Track 选项，SDK 会自动记录：
- ta_app_start 每次用户获得焦点（即在游戏中）
- ta_app_end 当游戏进入`Pause`状态，并附加`#duration`属性，记录本次游戏时长

1.1.0 版本开始，可以通过接口调用的方式采集安装事件：
```
// 采集 APP 安装事件
ThinkingAnalyticsAPI.TrackAppInstall();
```

#### 6 多项目 ID 支持

在配置 SDK 时，可以添加多个 APP ID，之后在调用 API 时，最后附加一个参数指定 APP ID. 以 `Identify()` 接口为例：
```
// 为 APP ID 为 “debug-appid” 的项目设置访客 ID
ThinkingAnalyticsAPI.Identify("unity_debug_id", "debug-appid");
```
> 注意：访客 ID、账户 ID、公共属性等值在多项目中不共享，需要单独设置

如果没有附加 APP ID 参数，则默认使用 列表中第一个 APP ID。您可以拖动列表项，调整列表顺序。

#### 7 其他配置选项
7.1 设置上报数据到服务器的网络条件, Network Type:

- DEFAULT：3G, 4G, 5G 及 WIFI 
- WIFI：只在 WIFI 环境下上报数据
- ALL：2G,3G, 4G, 5G 及 WIFI 

7.2 打开日志

如果勾选了 Enable Log 选项，将会开启日志，打印上报情况，以方便您的调试。您也可以在 Editor 模式下，检验事件上报是否正确，对于不符合条件的属性，会以`warning`日志显示在控制台中。

7.3 获取设备ID
```
ThinkingAnalyticsAPI.GetDeviceId()
```

7.4 Postpone Track

如果您勾选了 Postpone Track 选项，意味着所有的上报请求（包括用户属性设置和事件追踪）都会被缓存，直到您主动调用:
```
ThinkingAnalyticsAPI.StartTrack();
```

这个设置可以满足希望在上报之前完成设置访客ID，公共属性等初始化的场景。
