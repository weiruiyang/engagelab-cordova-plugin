# engagelab-cordova-plugin
cordova plugin for push SDK
## Install

- 直接通过 url 安装：

  ```shell
  cordova plugin add https://github.com/DevEngageLab/engagelab-cordova-plugin.git --variable ENGAGELAB_PRIVATES_APPKEY=your_APPKEY --variable CLIENT_ID=  --variable PROJECT_NUMBER=  --variable CURRENT_KEY=  --variable MOBILESDK_APP_ID=  --variable STORAGE_BUCKET=  --variable PROJECT_ID=  --variable HUAWEI_APP_ID=  --variable VIVO_APPID=  --variable VIVO_APPKEY=  --variable OPPO_APPID=  --variable OPPO_APPKEY=  --variable OPPO_APPSECRET=  --variable MEIZU_APPID=  --variable MEIZU_APPKEY=  --variable XIAOMI_GLOBAL_APPID=  --variable XIAOMI_GLOBAL_APPKEY=  
  ```

- 或下载到本地安装：

  ```shell
  cordova plugin add Your_Plugin_Path --variable ENGAGELAB_PRIVATES_APPKEY=your_APPKEY --variable CLIENT_ID=  --variable PROJECT_NUMBER=  --variable CURRENT_KEY=  --variable MOBILESDK_APP_ID=  --variable STORAGE_BUCKET=  --variable PROJECT_ID=  --variable HUAWEI_APP_ID=  --variable VIVO_APPID=  --variable VIVO_APPKEY=  --variable OPPO_APPID=  --variable OPPO_APPKEY=  --variable OPPO_APPSECRET=  --variable MEIZU_APPID=  --variable MEIZU_APPKEY=  --variable XIAOMI_GLOBAL_APPID=  --variable XIAOMI_GLOBAL_APPKEY=  
  ```


### 参数

- ENGAGELAB_PRIVATES_APPKEY: 必须设置，ENGAGELAB 上注册的包名对应的 Appkey

  ```shell
  --variable ENGAGELAB_PRIVATES_APPKEY=your_APPKEY
  ```

- goole : 必须设置，对应google-services.json中的内容，如果没有可填空.

  ```shell
  --variable CLIENT_ID=
  --variable PROJECT_NUMBER=
  --variable CURRENT_KEY=
  --variable MOBILESDK_APP_ID=
  --variable STORAGE_BUCKET=
  --variable PROJECT_ID=
  ```
  
- HUAWEI厂商 : 必须设置，对应agconnect-services.json里的app_id如果没有可填空.
  ```shell
  --variable HUAWEI_APP_ID=
  ```
  
- VIVO厂商 : 必须设置，如果没有可填空.

  ```shell
  --variable VIVO_APPID=
  --variable VIVO_APPKEY=
  ```
  
- OPPO厂商 : 必须设置，如果没有可填空.

  ```shell
  --variable OPPO_APPID=
  --variable OPPO_APPKEY=
  --variable OPPO_APPSECRET=
  ```
  
- MEIZU厂商 : 必须设置，如果没有可填空.
  ```shell
  --variable MEIZU_APPID=
  --variable MEIZU_APPKEY=
  ```

- XIAOMI厂商 : 必须设置，如果没有可填空.
  ```shell
  --variable XIAOMI_GLOBAL_APPID=
  --variable XIAOMI_GLOBAL_APPKEY=
  ```

- ENGAGELAB_PRIVATES_CHANNEL: 可以不设置，默认为 developer-default.

  ```shell
  --variable ENGAGELAB_PRIVATES_CHANNEL=your_channel
  ```

- ENGAGELAB_PRIVATES_PROCESS: 可以不设置，默认为 :remote.

  ```shell
  --variable ENGAGELAB_PRIVATES_PROCESS=:your_process
  ```

