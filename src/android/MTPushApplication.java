package com.engagelab.push;


import android.app.Application;

import com.engagelab.privates.core.api.MTCorePrivatesApi;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class MTPushApplication extends Application {
    private static final String TAG = "MTPushApplication";

    @Override
    public void onCreate() {
        super.onCreate();
        init();
    }

    public void init() {
        try {
            String mtpush_config = getFromAssets("mt_engagelab_cordova_push_config");
            if (null != mtpush_config) {
                MTPushEngagelab.logD(TAG, "mt_engagelab_cordova_push_config:" + mtpush_config);
                JSONObject jsonObject = new JSONObject(mtpush_config);
                setDebug(jsonObject);
                setTcpSSL(jsonObject);
            } else {
                MTPushEngagelab.logD(TAG, "mt_engagelab_cordova_push_config is null");
            }
        } catch (Throwable e) {
            e.printStackTrace();
            MTPushEngagelab.logE(TAG, "init is e:" + e);
        }
    }

    private void setDebug(JSONObject jsonObject) {
        if (jsonObject.has("debug")){
            boolean debug = jsonObject.optBoolean("debug", false);
            MTCorePrivatesApi.configDebugMode(getApplicationContext(),debug);
            MTPushEngagelab.DEBUG = debug;
        }
    }
    private void setTcpSSL(JSONObject jsonObject) {
        if (jsonObject.has("tcp_ssl")){
            boolean tcp_ssl = jsonObject.optBoolean("tcp_ssl", false);
            MTCorePrivatesApi.setTcpSSl(tcp_ssl);
        }
    }


    public String getFromAssets(String fileName) {
        try {
            InputStreamReader inputReader = new InputStreamReader(getResources().getAssets().open(fileName));
            BufferedReader bufReader = new BufferedReader(inputReader);
            String line = "";
            String Result = "";
            while ((line = bufReader.readLine()) != null)
                Result += line;
            return Result;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
