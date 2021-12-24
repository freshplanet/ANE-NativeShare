/*
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.freshplanet.ane.AirNativeShare.functions;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.provider.MediaStore;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirNativeShare.AirNativeShareExtension;

public class ShareToStoryFunction extends BaseFunction {
	public FREObject call(FREContext context, FREObject[] args) {
		super.call(context, args);


		String appId = getStringFromFREObject(args[0]);
		Bitmap bitmap = getBitmapFromFREBitmapData(args[1]);
		String provider = getStringFromFREObject(args[2]);

		String pathOfBmp = MediaStore.Images.Media.insertImage(context.getActivity().getContentResolver(), bitmap, "air_native_share_media", "");
		Uri bitmapUri = Uri.parse(pathOfBmp);

		String intentName;
		if(provider.equals("facebook")) {
			intentName = "com.facebook.stories.ADD_TO_STORY";
		}
		else  { // if(provider.equals("instagram")) default to instagram
			intentName = "com.instagram.share.ADD_TO_STORY";
		}

		Intent intent = new Intent(intentName);
		intent.setDataAndType(bitmapUri, "image/jpeg");
		intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		if(provider.equals("facebook")) {
			intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId);
		}
		else {
			intent.putExtra("source_application", appId);
		}

		// Instantiate activity and verify it will resolve implicit intent
		Activity activity = context.getActivity();
		if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
			activity.startActivityForResult(intent, 0);
			AirNativeShareExtension.dispatchEvent("AirNativeShareEvent_didShare", "");
		}
		else {
			AirNativeShareExtension.dispatchEvent("AirNativeShareEvent_cancelled", "");
		}

		return null;

	}

}