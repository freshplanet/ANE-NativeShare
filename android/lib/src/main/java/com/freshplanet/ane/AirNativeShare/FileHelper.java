package com.freshplanet.ane.AirNativeShare;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;

import androidx.core.content.FileProvider;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FileHelper {

    public static ArrayList<Uri> saveBitmapsForSharing(Activity activity, List<Bitmap> bitmaps) {
        ArrayList<Uri> files = new ArrayList<Uri>();
        try {
            for (Bitmap bitmap : bitmaps) {
                files.add(saveBitmapForSharing(activity, bitmap));
            }
            return files;
        } catch (IOException e) {
            Log.e("AirNativeShare", "Failed to save bitmaps ", e);
            return files;
        }
    }

    public static Uri saveBitmapForSharing(Activity activity, Bitmap bitmap) throws IOException {
            File tmpFile = getTemporaryFile(activity.getApplicationContext(), ".jpg");
            FileOutputStream stream = new FileOutputStream(tmpFile);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, stream);
            stream.flush();
            stream.close();

            Uri imageUri = FileProvider.getUriForFile(activity.getBaseContext(),
                    activity.getBaseContext().getPackageName() + ".provider",
                    tmpFile);
            return imageUri;
    }

    private static File getTemporaryFile(Context context, String extension ) {

        File tempFolder = new File(context.getCacheDir(), "airImagePicker");

        if (!tempFolder.exists()) {
            tempFolder.mkdirs();

            try {
                new File(tempFolder, ".nomedia").createNewFile();
            }
            catch (Exception e) {
                Log.e("AirNativeShareExtension", "Couldn't create temporary file with extension '" + extension + "'");
            }
        }

        // Create temp file
        try {
            return new File(tempFolder, String.valueOf(System.currentTimeMillis())+extension);
        } catch (Exception e) {
            Log.e("AirNativeShareExtension", "Couldn't create temp file");
        }
        return null;
    }
}
