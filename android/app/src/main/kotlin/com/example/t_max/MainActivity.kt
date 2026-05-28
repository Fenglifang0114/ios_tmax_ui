package com.example.t_max

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import tmaxbackend.Tmaxbackend
import android.provider.Settings
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tmax.service/backend"
    private var backendStarted = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startGoBackend()
    }

    private fun startGoBackend() {
        if (backendStarted) return
        backendStarted = true
        Thread {
            try {
                val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: ""
                Log.d("Tmax", "Starting backend with path: ${filesDir.absolutePath} and androidId: $androidId")
                Tmaxbackend.startBackend(filesDir.absolutePath, androidId)
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
