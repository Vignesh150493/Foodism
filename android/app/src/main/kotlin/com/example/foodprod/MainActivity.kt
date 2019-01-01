package com.example.foodprod

import android.os.Bundle
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class MainActivity() : FlutterActivity() {

    companion object {
        private val CHANNEL: String = "platform-channel/battery"
    }

    private fun getBatteryLevel(): Int {
        var batteryLevel = - 1
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager: BatteryManager  = getSystemService (BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            intent  = ContextWrapper(applicationContext)
                    .registerReceiver(null,  IntentFilter (Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel;
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result ->
            if (methodCall.method.equals("getBatteryLevel")) {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Could not fetch Battery level", null)
                }
            } else {
                result.notImplemented()
            }
        }
        GeneratedPluginRegistrant.registerWith(this)
    }
}
