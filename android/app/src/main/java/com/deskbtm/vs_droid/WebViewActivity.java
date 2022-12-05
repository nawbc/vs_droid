package com.deskbtm.vs_droid;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.provider.Browser;
import android.view.KeyEvent;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.VisibleForTesting;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class WebViewActivity extends Activity {
    /*
     * Use this to trigger a BroadcastReceiver inside WebViewActivity
     * that will request the current instance to finish.
     * */
    public static String ACTION_CLOSE = "close action";

    private static String URL_EXTRA = "url";

    private final BroadcastReceiver broadcastReceiver =
            new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    String action = intent.getAction();
                    if (ACTION_CLOSE.equals(action)) {
                        finish();
                    }
                }
            };

    private final WebViewClient webViewClient =
            new WebViewClient() {

                @SuppressWarnings("deprecation")
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url) {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                        view.loadUrl(url);
                        return false;
                    }
                    return super.shouldOverrideUrlLoading(view, url);
                }

                @RequiresApi(Build.VERSION_CODES.N)
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        view.loadUrl(request.getUrl().toString());
                    }
                    return false;
                }
            };

    private WebView webview;

    private IntentFilter closeIntentFilter = new IntentFilter(ACTION_CLOSE);

    // Verifies that a url opened by `Window.open` has a secure url.
    private class FlutterWebChromeClient extends WebChromeClient {
        @Override
        public boolean onCreateWindow(
                final WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
            final WebViewClient webViewClient =
                    new WebViewClient() {
                        @TargetApi(Build.VERSION_CODES.LOLLIPOP)
                        @Override
                        public boolean shouldOverrideUrlLoading(
                                @NonNull WebView view, @NonNull WebResourceRequest request) {
                            webview.loadUrl(request.getUrl().toString());
                            return true;
                        }

                        /*
                         * This method is deprecated in API 24. Still overridden to support
                         * earlier Android versions.
                         */
                        @SuppressWarnings("deprecation")
                        @Override
                        public boolean shouldOverrideUrlLoading(WebView view, String url) {
                            webview.loadUrl(url);
                            return true;
                        }
                    };

            final WebView newWebView = new WebView(webview.getContext());
            newWebView.setWebViewClient(webViewClient);

            final WebView.WebViewTransport transport = (WebView.WebViewTransport) resultMsg.obj;
            transport.setWebView(newWebView);
            resultMsg.sendToTarget();

            return true;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        webview = new WebView(this);
        setContentView(webview);
        // Get the Intent that started this activity and extract the string
        final Intent intent = getIntent();
        final String url = intent.getStringExtra(URL_EXTRA);
        final Bundle headersBundle = intent.getBundleExtra(Browser.EXTRA_HEADERS);

        final Map<String, String> headersMap = extractHeaders(headersBundle);
        webview.loadUrl(url, headersMap);
        WebSettings webViewSettings =  webview.getSettings();

        webViewSettings.setJavaScriptEnabled(true);
        webViewSettings.setDomStorageEnabled(true);
        webViewSettings.setDatabaseEnabled(true);
        webViewSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webViewSettings.setUseWideViewPort(true);
        webViewSettings.setAllowFileAccess(true);
        webViewSettings.setLoadWithOverviewMode(true);
        webViewSettings.setLoadsImagesAutomatically(true);
        webViewSettings.setSupportMultipleWindows(true);

        // Open new urls inside the webview itself.
        webview.setWebViewClient(webViewClient);

        // Multi windows is set with FlutterWebChromeClient by default to handle internal bug: b/159892679.
        webview.setWebChromeClient(new FlutterWebChromeClient());

        // Register receiver that may finish this Activity.
        registerReceiver(broadcastReceiver, closeIntentFilter);
    }

    @VisibleForTesting
    public static Map<String, String> extractHeaders(@Nullable Bundle headersBundle) {
        if (headersBundle == null) {
            return Collections.emptyMap();
        }
        final Map<String, String> headersMap = new HashMap<>();
        for (String key : headersBundle.keySet()) {
            final String value = headersBundle.getString(key);
            headersMap.put(key, value);
        }
        return headersMap;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(broadcastReceiver);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && webview.canGoBack()) {
            webview.goBack();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    public static Intent createIntent(
            Context context,
            String url) {
        return new Intent(context, WebViewActivity.class)
                .putExtra(URL_EXTRA, url);
    }
}
