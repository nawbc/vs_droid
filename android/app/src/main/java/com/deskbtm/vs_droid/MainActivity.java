package com.deskbtm.vs_droid;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        flutterEngine.getPlugins().add(new StagePlugin());
        super.configureFlutterEngine(flutterEngine);
    }
}
