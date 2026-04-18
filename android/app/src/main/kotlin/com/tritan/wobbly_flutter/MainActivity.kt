package com.tritan.wobbly_flutter

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.tritan.wobbly_flutter/yandex_auth"
    private val clientId = "475c2604676240ec981f6a1b3752fde4"
    private val redirectUri = "yx${clientId}://auth/"
    private var pendingResult: MethodChannel.Result? = null

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
                            .appendQueryParameter("redirect_uri", redirectUri)
                            .build()
                        startActivity(Intent(Intent.ACTION_VIEW, authUrl))
                    }
                    "signOut" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val data = intent.data ?: return
        if (data.scheme == "yx$clientId") {
            val fragment = data.fragment ?: ""
            val params = fragment.split("&").associate { param ->
                val idx = param.indexOf('=')
                if (idx >= 0) param.substring(0, idx) to Uri.decode(param.substring(idx + 1))
                else param to ""
            }
            val token = params["access_token"]
            if (!token.isNullOrEmpty()) {
                pendingResult?.success(token)
            } else {
                pendingResult?.error("YANDEX_AUTH_FAILED", "No access token in redirect", null)
            }
            pendingResult = null
        }
    }

    override fun onDestroy() {
        pendingResult?.error("ACTIVITY_DESTROYED", "Activity was destroyed", null)
        pendingResult = null
        super.onDestroy()
    }
}
