package com.example.t_max

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import tmaxbackend.Tmaxbackend
import android.provider.Settings
import android.os.Build
import android.os.Bundle
import android.util.Log
import java.io.File
import java.security.MessageDigest
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tmax.service/backend"
    private var backendStarted = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startGoBackend()
    }

    private fun getStableMachineId(): String {
        // 1. Check SharedPreferences
        val prefs = applicationContext.getSharedPreferences("tmax_device_info", MODE_PRIVATE)
        var savedId = prefs.getString("stable_machine_id", null)

        // 2. Check external storage file backup
        val externalFile = File(applicationContext.getExternalFilesDir(null), ".machine_id")
        if (savedId.isNullOrEmpty() && externalFile.exists()) {
            try {
                savedId = externalFile.readText().trim()
            } catch (e: Exception) { }
        }

        if (!savedId.isNullOrEmpty() && savedId.length >= 10) {
            val validId = savedId.substring(0, 10)
            prefs.edit().putString("stable_machine_id", validId).apply()
            if (!externalFile.exists()) {
                try { externalFile.writeText(validId) } catch (e: Exception) {}
            }
            return validId
        }

        // 3. Fallback: calculate deterministic hash based on hardware fingerprint + ANDROID_ID
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
            .append(Build.BOARD)
            .toString()

        val seed = if (androidId.isNotEmpty() && androidId != "9774d56d682e549c" && androidId != "0000000000000000") {
            "$androidId-$rawHardwareInfo"
        } else {
            rawHardwareInfo
        }

        val md5Hash = md5(seed)
        val newMachineId = if (md5Hash.length >= 10) md5Hash.substring(0, 10) else md5Hash.padEnd(10, '0')

        // 4. Save to both SharedPreferences and file
        try {
            prefs.edit().putString("stable_machine_id", newMachineId).apply()
            externalFile.writeText(newMachineId)
        } catch (e: Exception) {}

        return newMachineId
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
                val machineId = getStableMachineId()
                val tz = TimeZone.getDefault().id
                Log.d("Tmax", "Starting backend with path: ${filesDir.absolutePath}, machineId: $machineId, tz: $tz")
                Tmaxbackend.startBackend(filesDir.absolutePath, machineId, tz)
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
