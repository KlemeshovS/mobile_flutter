package com.tritan.wobbly_flutter

import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.yandex.authsdk.YandexAuthLoginOptions
import com.yandex.authsdk.YandexAuthOptions
import com.yandex.authsdk.YandexAuthResult
import com.yandex.authsdk.YandexAuthSdk

class MainActivity : FlutterFragmentActivity() {

    private val channel = "com.tritan.wobbly_flutter/yandex_auth"
    private var pendingResult: MethodChannel.Result? = null
    private lateinit var yandexAuthSdk: YandexAuthSdk
    private lateinit var yandexAuthLauncher: ActivityResultLauncher<YandexAuthLoginOptions>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        yandexAuthSdk = YandexAuthSdk.create(YandexAuthOptions(this))
        yandexAuthLauncher = registerForActivityResult(yandexAuthSdk.contract) { result: YandexAuthResult ->
            when (result) {
                is YandexAuthResult.Success -> {
                    pendingResult?.success(result.token.value)
                    pendingResult = null
                }
                is YandexAuthResult.Failure -> {
                    pendingResult?.error("YANDEX_AUTH_FAILED", result.exception.message, null)
                    pendingResult = null
                }
                YandexAuthResult.Cancelled -> {
                    pendingResult?.error("YANDEX_AUTH_CANCELLED", "Cancelled by user", null)
                    pendingResult = null
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "signIn" -> {
                        pendingResult = result
                        yandexAuthLauncher.launch(YandexAuthLoginOptions())
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
