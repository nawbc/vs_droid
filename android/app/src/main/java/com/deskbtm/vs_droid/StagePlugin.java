package com.deskbtm.vs_droid;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public final class StagePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private static final String TAG = "StagePlugin";
    private static String CHANNEL_NAME = "com.deskbtm.vs_droid/stage";
    @Nullable
    private MethodChannel channel;
    @Nullable
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "launch":
                final String url = call.argument("url");
                launch(result, url);
                break;
            case "setZoom":
                final int val = call.argument("val");
                setZoom(result, val);
                break;
            default:
                result.notImplemented();
        }
    }

    void launch(@NonNull MethodChannel.Result result, String url) {
        Intent intent = WebViewActivity.createIntent(activity, url);
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
        try {
            activity.startActivity(intent);
            result.success(true);
        } catch (ActivityNotFoundException e) {
            Log.e(TAG, "WebViewActivity not found");
            result.error(TAG, e.getMessage(), e);
        }
    }

    void setZoom(@NonNull MethodChannel.Result result, int val) {
        if (WebViewActivity.webview != null) {
            WebViewActivity.webview.setInitialScale(val);
        }
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
        WebViewActivity.webview = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }
}
