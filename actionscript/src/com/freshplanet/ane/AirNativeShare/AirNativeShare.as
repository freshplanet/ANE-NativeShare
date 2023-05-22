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

package com.freshplanet.ane.AirNativeShare {

	import com.freshplanet.ane.AirNativeShare.events.AirNativeShareEvent;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;


	public class AirNativeShare extends EventDispatcher {
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//


		/** supported on iOS and Android devices. */
		public static function get isSupported() : Boolean {
			return isAndroid || isIOS;
		}

		/**
		 * If <code>true</code>, logs will be displayed at the Actionscript level.
		 */
		public function get logEnabled() : Boolean {
			return _logEnabled;
		}

		public function set logEnabled( value : Boolean ) : void {
			_logEnabled = value;
		}

		/**
		 * AirNativeShare instance
		 * @return AirNativeShare instance
		 */
		public static function get instance() : AirNativeShare {
			return _instance ? _instance : new AirNativeShare();
		}


		/**
		 * Show share dialog
		 * @param itemsToShare items must be a string or BitmapData
		 */
		public function showShare( itemsToShare:Array ) : void {

			if(!isSupported)
				return;

			if(isAndroid) {
				// wait for permission result first
				_itemsToShare = itemsToShare;
				_context.call("requestStoragePermission");
				return;
			}

			shareItems(itemsToShare);

		}

		private function shareItems(itemsToShare:Array):void {
			var stringsToShare:Array = [];
			var imagesToShare:Array = [];

			for (var i:int = 0; i < itemsToShare.length; i++) {
				var object:Object = itemsToShare[i];
				if (object is String) {
					stringsToShare.push(object);
				}
				else if (object is BitmapData) {
					imagesToShare.push(object);
				}
				else {
					log("Detected incorrect parameter in itemsToShare. Only String and BitmapData objects are allowed. Will skip this parameter.");
				}
			}

			_context.call("showShareDialog", stringsToShare, imagesToShare);
		}

		/**
		 * Show custom share dialog with platform specific texts. iOS ONLY
		 */
		public function showShareWithCustomTexts( customTexts:AirNativeShareCustomText, url:String = null, bitmapData:BitmapData = null ) : void {

			if(!isIOS)
				return;


			if(!url)
				url = "";

			if(bitmapData != null)
				_context.call("showShareWithCustomTexts", customTexts, url, bitmapData);
			else
				_context.call("showShareWithCustomTexts", customTexts, url);
		}


		public static const PROVIDER_FACEBOOK:String = "facebook";
		public static const PROVIDER_INSTAGRAM:String = "instagram";
		/**
		 * Share to Instagram of Facebook story
		 * @param appId - FBAppId for Facebook, app identifier for Instagram
		 * @param bitmapData
		 * @param provider
		 */
		public function shareToStory(appId:String, bitmapData:BitmapData, provider:String):void {
			if(!bitmapData)
				return;

			_context.call("shareToStory", appId, bitmapData, provider);
		}

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

		private static const EXTENSION_ID : String = "com.freshplanet.ane.AirNativeShare";
		private static var _instance : AirNativeShare;
		private var _context : ExtensionContext = null;
		private var _logEnabled : Boolean = true;
		private var _itemsToShare:Array = null;

		/**
		 * "private" singleton constructor
		 */
		public function AirNativeShare() {
			if (!_instance) {
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context) {
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);

				_instance = this;
			}
			else {
				throw Error("This is a singleton, use instance, do not call the constructor directly.");
			}
		}

		private function onStatus( event : StatusEvent ) : void {
			if (event.code == AirNativeShareEvent.DID_SHARE) {
				this.dispatchEvent(new AirNativeShareEvent(AirNativeShareEvent.DID_SHARE, event.level));

			} else if (event.code == AirNativeShareEvent.CANCELLED) {
				this.dispatchEvent(new AirNativeShareEvent(AirNativeShareEvent.CANCELLED, null));
			} else if (event.code == "permission_result") {
				if(event.level == "granted" && _itemsToShare) {
					shareItems(_itemsToShare.concat());
				}
				else if(event.level == "denied") {
					this.dispatchEvent(new AirNativeShareEvent(AirNativeShareEvent.DENIED, null));
				}
				_itemsToShare = null;
			}
			else if (event.code == "log") {
				log(event.level);
			}
		}

		private function log(message:String):void {
			if (_logEnabled) trace("[AirNativeShare] " + message);
		}

		private static function get isAndroid():Boolean {
			return Capabilities.manufacturer.indexOf("Android") > -1;
		}

		private static function get isIOS():Boolean {
			return Capabilities.manufacturer.indexOf("iOS") > -1 && Capabilities.os.indexOf("x86_64") < 0 && Capabilities.os.indexOf("i386") < 0;
		}
	}
}