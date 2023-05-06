// var exec = require('cordova/exec');
//
// exports.coolMethod = function (arg0, success, error) {
//     exec(success, error, 'MTPushEngagelab', 'coolMethod', [arg0]);
// };


var MTPushEngagelab = function () {
    MTPushEngagelab.debug = false
};
MTPushEngagelab.prototype.onMTCommonReceiver = function (data) {
    data = JSON.stringify(data);
    console.log("MTPushEngagelab onMTCommonReceiver data debug: " + MTPushEngagelab.debug);
    if (MTPushEngagelab.debug) {
        console.log("MTPushEngagelab onMTCommonReceiver data: " + data);
    }
    cordova.fireDocumentEvent("MTPushEngagelab.onMTCommonReceiver", JSON.parse(data));

}

MTPushEngagelab.prototype.errorCallback = function (msg) {
    console.log("MTPushEngagelab errorCallback Error: " + msg);
};


MTPushEngagelab.prototype.callNative = function (
    name,
    args,
    successCallback,
    errorCallback
) {
    if (errorCallback) {
        cordova.exec(successCallback, errorCallback, "MTPushEngagelab","channelMTPushEngagelab", [name, args]);
    } else {
        cordova.exec(
            successCallback,
            this.errorCallback,
            "MTPushEngagelab",
            "channelMTPushEngagelab",
            [name, args]
        );
    }
};

MTPushEngagelab.prototype.init = function () {
    console.log("MTPushEngagelab init");
    this.callNative("init", [], null);
};

/**
 * 设置心跳时间间隔
 * <p>
 * 需要在Application.onCreate()方法中调用
 *
 * @param heartbeatInterval 时间单位为毫秒、必须大于0、默认值是4分50秒\
 */
MTPushEngagelab.prototype.configHeartbeatIntervalAndroid = function (heartbeatInterval) {
    console.log("configHeartbeatInterval" + heartbeatInterval);
    this.callNative("configHeartbeatInterval", [heartbeatInterval], null);
};

/**
 * 设置长连接重试次数
 * <p>
 * 需要在Application.onCreate()方法中调用
 * @param connectRetryCount 重试的次数、默认值为3、最少3次
 */
MTPushEngagelab.prototype.configConnectRetryCountAndroid = function (connectRetryCount) {
    console.log("configConnectRetryCount" + connectRetryCount);
    this.callNative("configConnectRetryCount", [connectRetryCount], null);
}

/**
 * 设置是否debug模式，debug模式会打印更对详细日志
 * <p>
 * 需要在Application.onCreate()方法中调用
 *
 * @param context 不为空
 * @param enable  是否调试模式，true为调试模式，false不是
 */
MTPushEngagelab.prototype.configDebugMode = function (enable) {
    MTPushEngagelab.debug = enable;
    console.log("configDebugMode:" + enable);
    this.callNative("configDebugMode", [enable], null);
}

/**
 * 设置tcp 是否使用ssl
 * <p>
 * 初始化前调用
 * @param enable  设置tcp 是否使用ssl，true为使用ssl，false为不使用ssl
 */
MTPushEngagelab.prototype.setTcpSSL = function (enable) {
    console.log("setTcpSSL:" + enable);
    this.callNative("setTcpSSL", [enable], null);
}

/**
 * 配置使用国密加密
 *
 * @param context 不为空
 */
MTPushEngagelab.prototype.configSM4Android = function () {
    console.log("configSM4");
    this.callNative("configSM4", [], null);
}

/**
 * 获取当前设备的userId，Engagelab私有云唯一标识，可同于推送
 *
 * @param context 不为空
 * @return userId
 */
MTPushEngagelab.prototype.getUserIdAndroid = function (successCallback, errorCallback) {
    console.log("getUserId");
    this.callNative("getUserId", [], successCallback, errorCallback);
}

/**
 * 获取当前设备的registrationId，Engagelab私有云唯一标识，可同于推送
 *
 * @param context 不为空
 * @return registrationId
 */
MTPushEngagelab.prototype.getRegistrationId = function (successCallback, errorCallback) {
    console.log("getRegistrationId");
    this.callNative("getRegistrationId", [], successCallback, errorCallback);
}

//    // 继承MTCommonReceiver后，复写onNotificationStatus方法，获取通知开关状态，如果enable为true说明已经开启成功
//    @Override
//    public void onNotificationStatus(Context context, boolean enable) {
//        if(enable){
//            // 已设置通知开关为打开
//        }
//    }
//    启动sdk后可根据onNotificationStatus回调结果，再决定是否需要调用此借口
/**
 * 前往通知开关设置页面
 *
 * @param context 不为空 //TODO weiry
 */
MTPushEngagelab.prototype.goToAppNotificationSettingsAndroid = function () {
    console.log("goToAppNotificationSettings");
    this.callNative("goToAppNotificationSettings", [], null);
}


//    // 继承MTCommonReceiver后，复写onConnectStatus方法，获取长连接的连接状态，如果enable为true说明已经开启成功
//    @Override
//    public void onConnectStatus(Context context, boolean enable){
//        if(enable){
//            // 开启 push 推送成功
//        }
//    }

/**
 * 开启 Push 推送，并持久化存储开关状态为true，默认是true
 *
 * @param context 不能为空
 */
MTPushEngagelab.prototype.turnOnPushAndroid = function () {
    console.log("turnOnPush");
    this.callNative("turnOnPush", [], null);
}

//    // 继承MTCommonReceiver后，复写onConnectStatus方法，获取长连接的连接状态，如果enable为true说明已经开启成功
//    @Override
//    public void onConnectStatus(Context context, boolean enable){
//        if(enable){
//            // 开启 push 推送成功
//        }
//    }
/**
 * 关闭 push 推送，并持久化存储开关状态为false，默认是true
 *
 * @param context 不能为空
 */
MTPushEngagelab.prototype.turnOffPushAndroid = function () {
    console.log("turnOffPush");
    this.callNative("turnOffPush", [], null);
}

/**
 * 设置通知展示时间，默认任何时间都展示
 *
 * @param context   不为空
 * @param beginHour 允许通知展示的开始时间（ 24 小时制，范围为 0 到 23 ）
 * @param endHour   允许通知展示的结束时间（ 24 小时制，范围为 0 到 23 ），beginHour不能大于等于endHour
 * @param weekDays  允许通知展示的星期数组（ 7 日制，范围为 1 到 7），空数组代表任何时候都不展示通知
 */
MTPushEngagelab.prototype.setNotificationShowTimeAndroid = function (beginHour, endHour, weekDays) {
    console.log("setNotificationShowTime");
    this.callNative("setNotificationShowTime", [beginHour, endHour, weekDays], null);
}

/**
 * 重置通知展示时间，默认任何时间都展示
 *
 * @param context 不为空
 */
MTPushEngagelab.prototype.resetNotificationShowTimeAndroid = function () {
    console.log("resetNotificationShowTime");
    this.callNative("resetNotificationShowTime", [], null);
}


/**
 * 设置通知静默时间，默认任何时间都不静默
 *
 * @param context     不为空
 * @param beginHour   允许通知静默的开始时间，单位小时（ 24 小时制，范围为 0 到 23 ）
 * @param beginMinute 允许通知静默的开始时间，单位分钟（ 60 分钟制，范围为 0 到 59 ）
 * @param endHour     允许通知静默的结束时间，单位小时（ 24 小时制，范围为 0 到 23 ）
 * @param endMinute   允许通知静默的结束时间，单位分钟（ 60 分钟制，范围为 0 到 59 ）
 */
MTPushEngagelab.prototype.setNotificationSilenceTimeAndroid = function (beginHour, beginMinute, endHour, endMinute) {
    console.log("setNotificationSilenceTime");
    this.callNative("setNotificationSilenceTime", [beginHour, beginMinute, endHour, endMinute], null);
}

/**
 * 重置通知静默时间，默认任何时间都不静默
 *
 * @param context 不为空
 */
MTPushEngagelab.prototype.resetNotificationSilenceTimeAndroid = function () {
    console.log("resetNotificationSilenceTime");
    this.callNative("resetNotificationSilenceTime", [], null);
}


/**
 * 设置通知栏的通知数量，默认数量为5
 *
 * @param context 不为空
 * @param count   限制通知栏的通知数量，超出限制数量则移除最老通知，不能小于等于0
 */
MTPushEngagelab.prototype.setNotificationCountAndroid = function (count) {
    console.log("setNotificationCount");
    this.callNative("setNotificationCount", [count], null);
}

/**
 * 重置通知栏的通知数量，默认数量为5
 *
 * @param context 不为空
 */
MTPushEngagelab.prototype.resetNotificationCountAndroid = function () {
    console.log("resetNotificationCount");
    this.callNative("resetNotificationCount", [], null);
}

/**
 * 设置应用角标数量，默认0（仅华为/荣耀/ios生效）
 *
 * @param context 不为空
 * @param badge   应用角标数量
 */
MTPushEngagelab.prototype.setNotificationBadge = function (badge) {
    console.log("setNotificationBadge");
    this.callNative("setNotificationBadge", [badge], null);
}

/**
 * 重置应用角标数量，默认0（仅华为/荣耀生效/ios）
 *
 * @param context 不为空
 */
MTPushEngagelab.prototype.resetNotificationBadge = function () {
    console.log("resetNotificationBadge");
    this.callNative("resetNotificationBadge", [], null);
}

/**
 * 上报厂商通道通知到达
 * <p>
 * 走http/https上报
 *
 * @param context           不为空
 * @param messageId         Engagelab消息id，不为空
 * @param platform          厂商，取值范围（1:mi、2:huawei、3:meizu、4:oppo、5:vivo、8:google）
 * @param platformMessageId 厂商消息id，可为空
 */
MTPushEngagelab.prototype.reportNotificationArrivedAndroid = function (messageId, platform, platformMessageId) {
    console.log("reportNotificationArrived");
    this.callNative("reportNotificationArrived", [messageId, platform, platformMessageId], null);
}

/**
 * 上报厂商通道通知点击
 * <p>
 * 走http/https上报
 *
 * @param context           不为空
 * @param messageId         Engagelab消息id，不为空
 * @param platform          厂商，取值范围（1:mi、2:huawei、3:meizu、4:oppo、5:vivo、8:google）
 * @param platformMessageId 厂商消息id，可为空
 */
MTPushEngagelab.prototype.reportNotificationClickedAndroid = function (messageId, platform, platformMessageId) {
    console.log("reportNotificationClicked");
    this.callNative("reportNotificationClicked", [messageId, platform, platformMessageId], null);
}


/**
 * 上报厂商通道通知删除
 * <p>
 * 走http/https上报
 *
 * @param context           不为空
 * @param messageId         Engagelab消息id，不为空
 * @param platform          厂商，取值范围（1:mi、2:huawei、3:meizu、4:oppo、5:vivo、8:google）
 * @param platformMessageId 厂商消息id，可为空
 */
MTPushEngagelab.prototype.reportNotificationDeletedAndroid = function (messageId, platform, platformMessageId) {
    console.log("reportNotificationDeleted");
    this.callNative("reportNotificationDeleted", [messageId, platform, platformMessageId], null);
}

/**
 * 上报厂商通道通知打开
 * <p>
 * 走http/https上报
 *
 * @param context           不为空
 * @param messageId         Engagelab消息id，不为空
 * @param platform          厂商，取值范围（1:mi、2:huawei、3:meizu、4:oppo、5:vivo、8:google）
 * @param platformMessageId 厂商消息id，可为空
 */
MTPushEngagelab.prototype.reportNotificationOpenedAndroid = function (messageId, platform, platformMessageId) {
    console.log("reportNotificationOpened");
    this.callNative("reportNotificationOpened", [messageId, platform, platformMessageId], null);
}


/**
 * 上传厂商token
 * <p>
 * 走tcp上传
 *
 * @param context  不为空
 * @param platform 厂商，取值范围（1:mi、2:huawei、3:meizu、4:oppo、5:vivo、8:google）
 * @param token    厂商返回的token，不为空
 * @param region    //目前只有小米、OPPO才区分国内和国际版，其他厂商不区分;没有不用传
 */
MTPushEngagelab.prototype.uploadPlatformTokenAndroid = function (platform, token, region) {
    console.log("uploadPlatformToken");
    this.callNative("uploadPlatformToken", [platform, token, region], null);
}


if (!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.mTPushEngagelab) {
    window.plugins.mTPushEngagelab = new MTPushEngagelab();
}

module.exports = new MTPushEngagelab();