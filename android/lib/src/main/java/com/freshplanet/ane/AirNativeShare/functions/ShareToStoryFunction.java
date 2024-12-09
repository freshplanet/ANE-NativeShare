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
import android.content.pm.PackageManager;
import android.content.pm.PackageInfo;
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
		Activity activity = context.getActivity();
		Uri bitmapUri = saveBitmapToGallery(activity, bitmap);

		ShareProviderDetails providerDetails = getProviderDetails(provider);
		if (isAppInstalled(activity, providerDetails.packageName)) {
			shareImage(activity, bitmapUri, appId, providerDetails);
		} else {
			navigateToAppStore(activity, providerDetails.appStoreLink);
		}

		return null;
	}

	private Uri saveBitmapToGallery(Activity activity, Bitmap bitmap) {
		String pathOfBmp = MediaStore.Images.Media.insertImage(activity.getContentResolver(), bitmap, "air_native_share_media", "");
		return Uri.parse(pathOfBmp);
	}

	private ShareProviderDetails getProviderDetails(String provider) {
		if (provider.equals("facebook")) {
			return new ShareProviderDetails("com.facebook.stories.ADD_TO_STORY",
					"https://play.google.com/store/apps/details?id=com.facebook.katana",
					"com.facebook.katana");
		} else { // Default to Instagram
			return new ShareProviderDetails("com.instagram.share.ADD_TO_STORY",
					"https://play.google.com/store/apps/details?id=com.instagram.android",
					"com.instagram.android");
		}
	}

	private void shareImage(Activity activity, Uri bitmapUri, String appId, ShareProviderDetails providerDetails) {
		Intent intent = new Intent(providerDetails.intentName);
		intent.setDataAndType(bitmapUri, "image/jpeg");
		intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

		if (providerDetails.packageName.equals("com.facebook.katana")) {
			intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId);
		} else {
			intent.putExtra("source_application", appId);
		}

		if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
			activity.startActivityForResult(intent, 0);
			AirNativeShareExtension.dispatchEvent("AirNativeShareEvent_didShare", "");
		} else {
			AirNativeShareExtension.dispatchEvent("AirNativeShareEvent_cancelled", "");
		}
	}

	private void navigateToAppStore(Activity activity, String appStoreLink) {
		Uri appStoreURI = Uri.parse(appStoreLink);
		Intent navIntent = new Intent(Intent.ACTION_VIEW, appStoreURI);
		if (activity.getPackageManager().resolveActivity(navIntent, 0) != null) {
			activity.startActivityForResult(navIntent, 0);
		}
		AirNativeShareExtension.dispatchEvent("AirNativeShareEvent_cancelled", "");
	}

	private static class ShareProviderDetails {
		String intentName;
		String appStoreLink;
		String packageName;

		ShareProviderDetails(String intentName, String appStoreLink, String packageName) {
			this.intentName = intentName;
			this.appStoreLink = appStoreLink;
			this.packageName = packageName;
		}
	}

	private boolean isAppInstalled(Activity activity, String packageName) {
		try {
			PackageInfo packageInfo = activity.getPackageManager().getPackageInfo(packageName, 0);
			return packageInfo != null;
		} catch (PackageManager.NameNotFoundException e) {
			return false;
		}
	}

}