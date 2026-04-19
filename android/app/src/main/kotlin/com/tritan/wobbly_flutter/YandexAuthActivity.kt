package com.tritan.wobbly_flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient

class YandexAuthActivity : Activity() {

    companion object {
        const val EXTRA_AUTH_URL = "auth_url"
        const val EXTRA_TOKEN = "token"
        const val REDIRECT_URI = "https://oauth.yandex.ru/verification_code"
    }

    private lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        webView = WebView(this)
        setContentView(webView)

        webView.settings.javaScriptEnabled = true
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                val url = request.url.toString()
                if (url.startsWith(REDIRECT_URI)) {
                    handleRedirect(request.url)
                    return true
                }
                return false
            }
        }

        val authUrl = intent.getStringExtra(EXTRA_AUTH_URL) ?: run {
            setResult(RESULT_CANCELED)
            finish()
            return
        }
        webView.loadUrl(authUrl)
    }

    private fun handleRedirect(uri: Uri) {
        val fragment = uri.fragment ?: ""
        val params = fragment.split("&").associate { param ->
            val idx = param.indexOf('=')
            if (idx >= 0) param.substring(0, idx) to Uri.decode(param.substring(idx + 1))
            else param to ""
        }
        val token = params["access_token"]
        if (!token.isNullOrEmpty()) {
            val result = Intent().putExtra(EXTRA_TOKEN, token)
            setResult(RESULT_OK, result)
        } else {
            setResult(RESULT_CANCELED)
        }
        finish()
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (webView.canGoBack()) webView.goBack()
        else {
            setResult(RESULT_CANCELED)
            @Suppress("DEPRECATION")
            super.onBackPressed()
        }
    }
}
