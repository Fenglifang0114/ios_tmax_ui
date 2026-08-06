package com.example.t_max

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import tmaxbackend.Tmaxbackend
import android.provider.Settings
import android.os.Build
import android.os.Bundle
import android.util.Log
import java.security.MessageDigest

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tmax.service/backend"
    private var backendStarted = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startGoBackend()
    }

    private fun getDeterministicHardwareId(): String {
        val androidId = try {
            Settings.Secure.getString(applicationContext.contentResolver, Settings.Secure.ANDROID_ID) ?: ""
        } catch (e: Exception) { "" }

        val rawHardwareInfo = StringBuilder()
            .append(Build.BRAND)
            .append("-")
            .append(Build.MODEL)
            .append("-")
            .append(Build.DEVICE)
            .append("-")
            .append(Build.HARDWARE)
            .append("-")
            .append(Build.MANUFACTURER)
            .append("-")
            .append(Build.FINGERPRINT)
            .toString()

        val combined = if (androidId.isNotEmpty() && androidId != "9774d56d682e549c" && androidId != "0000000000000000") {
            "$androidId-$rawHardwareInfo"
        } else {
            rawHardwareInfo
        }

        val md5Hash = md5(combined)
        return if (md5Hash.length >= 10) md5Hash.substring(0, 10) else md5Hash.padEnd(10, '0')
    }

    private fun md5(input: String): String {
        val md = MessageDigest.getInstance("MD5")
        val digest = md.digest(input.toByteArray())
        return digest.joinToString("") { "%02x".format(it) }
    }

    private fun startGoBackend() {
        if (backendStarted) return
        backendStarted = true
        Thread {
            try {
                val machineId = getDeterministicHardwareId()
                Log.d("Tmax", "Starting backend with path: ${filesDir.absolutePath} and machineId: $machineId")
                Tmaxbackend.startBackend(filesDir.absolutePath, machineId)
                Log.d("Tmax", "Backend startBackend returned")
            } catch (e: Exception) {
                Log.e("Tmax", "Failed to start backend", e)
            }
        }.start()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startBackend") {
                startGoBackend()
                result.success("Backend start requested")
            } else {
                result.notImplemented()
            }
        }
    }
}
