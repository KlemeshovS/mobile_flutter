package com.tritan.wobbly_flutter

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.yandex.authsdk.YandexAuthLoginOptions
import com.yandex.authsdk.YandexAuthOptions
import com.yandex.authsdk.YandexAuthSdk

class MainActivity : FlutterActivity() {

    private val channel = "com.tritan.wobbly_flutter/yandex_auth"
    private val yandexAuthRequestCode = 1001

    private lateinit var yandexAuthSdk: YandexAuthSdk
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        yandexAuthSdk = YandexAuthSdk.create(YandexAuthOptions(this))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "signIn" -> {
                        pendingResult = result
                        val loginIntent = yandexAuthSdk.createLoginIntent(YandexAuthLoginOptions())
                        startActivityForResult(loginIntent, yandexAuthRequestCode)
                    }
                    "signOut" -> {
                        yandexAuthSdk.tokenStorage.removeToken()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == yandexAuthRequestCode) {
            val authResult = yandexAuthSdk.getResultFromIntent(data)
            authResult
                .onSuccess { token ->
                    pendingResult?.success(token.value)
                    pendingResult = null
                }
                .onFailure { exception ->
                    pendingResult?.error("YANDEX_AUTH_FAILED", exception.message, null)
                    pendingResult = null
                }
        }
    }

    override fun onDestroy() {
        pendingResult?.error("ACTIVITY_DESTROYED", "Activity was destroyed", null)
        pendingResult = null
        super.onDestroy()
    }
}
