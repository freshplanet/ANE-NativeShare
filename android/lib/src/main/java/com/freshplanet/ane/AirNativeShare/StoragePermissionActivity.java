package com.freshplanet.ane.AirNativeShare;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class StoragePermissionActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(savedInstanceState != null) {
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            AirNativeShareExtension.dispatchEvent("permission_result", "granted");
            finish();
            return;
        }

        String permission = Manifest.permission.WRITE_EXTERNAL_STORAGE;
        if(ContextCompat.checkSelfPermission(getApplicationContext(), permission) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{permission}, 11);
        }
        else  {
            AirNativeShareExtension.dispatchEvent("permission_result", "granted");
            finish();
        }

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        int permissionCheck = PackageManager.PERMISSION_GRANTED;
        for (int permission : grantResults) {
            permissionCheck = permissionCheck + permission;
        }
        if ((grantResults.length > 0) && permissionCheck == PackageManager.PERMISSION_GRANTED) {
            // granted
            AirNativeShareExtension.dispatchEvent("permission_result", "granted");
        } else {
            // denied - do nothing
            AirNativeShareExtension.dispatchEvent("permission_result", "denied");
        }
        finish();
    }
}
