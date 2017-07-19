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

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.provider.MediaStore;
import android.text.TextUtils;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;

import java.util.ArrayList;
import java.util.List;

public class ShareFunction extends BaseFunction {
	public FREObject call(FREContext context, FREObject[] args) {
		super.call(context, args);

		List<String> messages = getListOfStringFromFREArray((FREArray) args[0]);
		List<Bitmap> bitmaps = getListOfBitmapFromFREArray((FREArray) args[1]);


		String joinedMessage = TextUtils.join("\n", messages);

		// ------------------------
		// Prepare Intent
		Intent sharingIntent = new Intent( bitmaps.size() > 1 ? Intent.ACTION_SEND_MULTIPLE : Intent.ACTION_SEND );

		sharingIntent.putExtra( Intent.EXTRA_TITLE, joinedMessage );
		sharingIntent.putExtra( Intent.EXTRA_SUBJECT, joinedMessage );
		sharingIntent.putExtra(Intent.EXTRA_TEXT, joinedMessage );

		ArrayList<Uri> files = new ArrayList<Uri>();


		for(Bitmap bitmap: bitmaps) {
			String pathOfBmp = MediaStore.Images.Media.insertImage(context.getActivity().getContentResolver(), bitmap, "air_native_share_media", "");
			Uri uri = Uri.parse(pathOfBmp);
			files.add(uri);
		}

		if(bitmaps.size() > 0) {
			sharingIntent.setType( "image/*" );
		}
		else {
			sharingIntent.setType( "text/plain" );
		}
		if (files.size() > 1) {
			sharingIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files);
		}
		else if (files.size() == 1) {
			sharingIntent.putExtra( Intent.EXTRA_STREAM, files.get(0) );
		}

		context.getActivity().startActivity( Intent.createChooser( sharingIntent, "Share with" ));

		return null;

	}

}