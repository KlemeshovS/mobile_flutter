package com.tritan.wobbly_flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val channel = "com.tritan.wobbly_flutter/yandex_auth"
    private val clientId = "475c2604676240ec981f6a1b3752fde4"
    private var pendingResult: MethodChannel.Result? = null
    private lateinit var yandexAuthLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        yandexAuthLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                val token = result.data?.getStringExtra(YandexAuthActivity.EXTRA_TOKEN)
                if (!token.isNullOrEmpty()) {
                    pendingResult?.success(token)
                } else {
                    pendingResult?.error("YANDEX_AUTH_FAILED", "No token received", null)
                }
            } else {
                pendingResult?.error("YANDEX_AUTH_CANCELLED", "Cancelled by user", null)
            }
            pendingResult = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "signIn" -> {
                        pendingResult = result
                        val authUrl = Uri.parse("https://oauth.yandex.ru/authorize").buildUpon()
                            .appendQueryParameter("response_type", "token")
                            .appendQueryParameter("client_id", clientId)
                            .appendQueryParameter("redirect_uri", YandexAuthActivity.REDIRECT_URI)
                            .build()
                            .toString()
                        val intent = Intent(this, YandexAuthActivity::class.java)
                            .putExtra(YandexAuthActivity.EXTRA_AUTH_URL, authUrl)
                        yandexAuthLauncher.launch(intent)
                    }
                    "signOut" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        pendingResult?.error("ACTIVITY_DESTROYED", "Activity was destroyed", null)
        pendingResult = null
        super.onDestroy()
    }
}
