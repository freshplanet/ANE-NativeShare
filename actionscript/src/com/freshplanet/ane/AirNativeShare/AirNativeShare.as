//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2014 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
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

package com.freshplanet.ane.AirNativeShare
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirNativeShare extends EventDispatcher
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//


		private static var isInitialized:Boolean = false;
		private static var _isSupportedOnIOS:Boolean = false;

		/** supported on iOS and Android devices. */
		public function get isSupported() : Boolean
		{
			if ( Capabilities.manufacturer.indexOf("Android") > -1) {
				return true;
			}
			
			if (isInitialized) {
				return _isSupportedOnIOS;
			} else {
				_isSupportedOnIOS = _context.call("AirNativeShareIsSupported") as Boolean;
				return _isSupportedOnIOS;
			}
		}

		public function AirNativeShare()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					throw Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);

				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}

		public static function getInstance() : AirNativeShare
		{
			return _instance ? _instance : new AirNativeShare();
		}


		public function showShare( shareObject:AirNativeShareObject, bitmapData:BitmapData = null ) : void
		{
			
			trace( "[AirNativeShare] show share:"+shareObject.messageText );
			trace( "[AirNativeShare] isSupported:" + isSupported );
			
			if (!isSupported) return;
			
			
			if (bitmapData) {
				trace( "[AirNativeShare] with bitmap" );
				_context.call("AirNativeShareShowShare", shareObject, bitmapData);
			} else {
				trace( "[AirNativeShare] without bitmap" );
				_context.call("AirNativeShareShowShare", shareObject);
			}
			trace( "[AirNativeShare] show share returned" );
		}

		public function initForPinterest(pinterestClientId:String, pinterestSiteUrl:String, pinterestClientSuffix:String = null):void
		{
			if (Capabilities.manufacturer.indexOf("Android") > -1 ) return;
			
			if (!isSupported) return;

			if (pinterestClientSuffix)
			{
				_context.call("AirNativeShareInitPinterest", pinterestClientId, pinterestSiteUrl, pinterestClientSuffix);
			} else
			{
				_context.call("AirNativeShareInitPinterest", pinterestClientId, pinterestSiteUrl);
			}

		}


		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

		private static const EXTENSION_ID : String = "com.freshplanet.AirNativeShare";

		private static var _instance : AirNativeShare;

		private var _context : ExtensionContext;

		private function onStatus( event : StatusEvent ) : void
		{
			if (event.code == AirNativeShareEvent.SHARED)
			{
				this.dispatchEvent(new AirNativeShareEvent(AirNativeShareEvent.SHARED, event.level));
			}
			else {
				trace( "[AirNativeShare]", event.level );
			}
		}
	}
}