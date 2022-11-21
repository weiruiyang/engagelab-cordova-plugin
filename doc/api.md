# API 说明

## 注册监听

### MTPushEngagelab.onMTCommonReceiver （android/ios都支持）

集成了 sdk 回调的事件

#### 参数说明
- dataAll:反回的事件数据
  - dataAll.event_name: 为事件类型
    - android:
      - "onNotificationStatus":应用通知开关状态回调,内容类型为boolean，true为打开，false为关闭
      - "onConnectStatus":长连接状态回调,内容类型为boolean，true为连接
      - "onNotificationArrived":通知消息到达回调，内容为通知消息体
      - "onNotificationClicked":通知消息点击回调，内容为通知消息体
      - "onNotificationDeleted":通知消息删除回调，内容为通知消息体
      - "onCustomMessage":自定义消息回调，内容为通知消息体
      - "onPlatformToken":厂商token消息回调，内容为厂商token消息体
    - ios:
      - "willPresentNotification":通知消息到达回调，内容为通知消息体
      - "didReceiveNotificationResponse":通知消息点击回调，内容为通知消息体
      - "networkDidReceiveMessage":自定义消息回调，内容为通知消息体
  - dataAll.event_data: 为对应内容


#### 代码示例

```js
document.addEventListener('MTPushEngagelab.onMTCommonReceiver', function (dataAll) {
  $("#notificationType").html(dataAll.event_name);
  $("#messageResult").html(JSON.stringify(dataAll.event_data));
  $("#messageResultAll").html("<br/>"+$("#messageResultAll").text() +"<br/>"+ JSON.stringify(dataAll));
}, false)
```

## 初始化

### init （android/ios都支持）

初始化sdk

#### 接口定义

```js
window.cordova.plugins.MTPushEngagelab.init();
```

## 开启 Debug 模式

### configDebugMode （android/ios都支持）

设置是否debug模式，debug模式会打印更对详细日志

#### 接口定义

```js
window.cordova.plugins.MTPushEngagelab.configDebugMode(enable)
```

#### 参数说明

- enable: 是否调试模式，true为调试模式，false不是

#### 代码示例

```js
window.cordova.plugins.MTPushEngagelab.configDebugMode(true)
```

## 获取 RegistrationID （android/ios都支持）

### getRegistrationId

RegistrationID 定义:
获取当前设备的registrationId，Engagelab私有云唯一标识，可同于推送

#### 接口定义

```js
window.cordova.plugins.MTPushEngagelab.getRegistrationId(successCallback)
```

#### 返回值

调用此 API 来取得应用程序对应的 RegistrationID。 只有当应用程序成功注册到 JPush 的服务器时才返回对应的值，否则返回空字符串。

#### 代码示例

```js
window.cordova.plugins.MTPushEngagelab.getRegistrationId(function(rId) {
  console.log("MTPushEngagelab:registrationID is " + rId)
})
```
