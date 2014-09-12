//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.nativeShare;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Paint;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREBitmapData;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FRENoSuchNameException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

import java.util.HashMap;
import java.util.Map;

public class ExtensionContext extends FREContext
{
	// Public API
	
	@Override
	public void dispose() { }

	@Override
	public Map<String, FREFunction> getFunctions()
	{

		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();

		functionMap.put("AirNativeShareShowShare", showShare );

		return functionMap;

	}

	private void log(String event){
		Log.i( "[AirNativeShare]", event );
		dispatchStatusEventAsync("log", event);
	}

	private FREFunction showShare = new FREFunction() {
		@Override
		public FREObject call(FREContext context, FREObject[] args) {
			Extension.log( "Native show Share start");

			String message = null;
			String link = null;
			Bitmap bitmap = null;

			try {

				FREObject freShareObject = args[0];
				message = freShareObject.getProperty("messageText").getAsString();
				link = freShareObject.getProperty("defaultLink").getAsString();

				if( args.length > 1 ) {

					Extension.log( "getting bitmap");
					FREBitmapData freBitmapData = (FREBitmapData) args[1];

					Paint paint = new Paint();
					float[] bgrToRgbColorTransform  =
							{
									0,  0,  1f, 0,  0,
									0,  1f, 0,  0,  0,
									1f, 0,  0,  0,  0,
									0,  0,  0,  1f, 0
							};
					ColorMatrix colorMatrix 			= new ColorMatrix(bgrToRgbColorTransform);
					ColorMatrixColorFilter colorFilter	= new ColorMatrixColorFilter(colorMatrix);
					paint.setColorFilter(colorFilter);

					freBitmapData.acquire();
					int width = freBitmapData.getWidth();
					int height = freBitmapData.getHeight();
					bitmap = Bitmap.createBitmap( width, height, Bitmap.Config.ARGB_8888 );
					bitmap.copyPixelsFromBuffer(freBitmapData.getBits());
					freBitmapData.release();

					// Convert the bitmap from BGRA to RGBA.
					Canvas canvas	= new Canvas(bitmap);
					canvas.drawBitmap(bitmap, 0, 0, paint);

				}


			} catch (FREASErrorException e) {
				e.printStackTrace();
			} catch (FREInvalidObjectException e) {
				e.printStackTrace();
			} catch (FREWrongThreadException e) {
				e.printStackTrace();
			} catch (FRENoSuchNameException e) {
				e.printStackTrace();
			} catch (FRETypeMismatchException e) {
				e.printStackTrace();
			}

			Extension.log( message );

			if( message == null ) {
				Extension.log( "no message to send" );
				return null;
			}

			// ------------------------
			// Prepare Intent
			Intent sharingIntent = new Intent( Intent.ACTION_SEND );
			sharingIntent.putExtra( Intent.EXTRA_TITLE, message );
			sharingIntent.putExtra( Intent.EXTRA_SUBJECT, message );
			if( link != null )
				message = message + " - " + link;
			sharingIntent.putExtra( Intent.EXTRA_TEXT, message );
			if( bitmap != null ){
				Extension.log( "we have image" );
				try {
					String pathOfBmp = MediaStore.Images.Media.insertImage(getActivity().getContentResolver(), bitmap, "air_native_share_media", "");
					Extension.log( pathOfBmp );
					Uri bmpUri = Uri.parse(pathOfBmp);
					sharingIntent.setType( "image/*" );
					sharingIntent.putExtra( Intent.EXTRA_STREAM, bmpUri );
				} catch( Exception e ) {
					Extension.log( e.getMessage() );
				}
			} else {
				sharingIntent.setType("text/plain");
			}

			Extension.log( "sending" );
			getActivity().startActivity( Intent.createChooser( sharingIntent, "Share with" ) );

			return null;

		}
	};
	
}
