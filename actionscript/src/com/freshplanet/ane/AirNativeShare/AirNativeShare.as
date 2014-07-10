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

		/** AirAlert is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") != -1;
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

		public function showShare( shareObject:AirNativeShareObject ) : void
		{
			if (!isSupported) return;

			_context.call("AirNativeShareShowShare", shareObject);

		}


		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

		private static const EXTENSION_ID : String = "com.freshplanet.AirNativeShare";

		private static var _instance : AirNativeShare;

		private var _context : ExtensionContext;

		private var _callback1 : Function = null;
		private var _callback2 : Function = null;

		private function onStatus( event : StatusEvent ) : void
		{
			if (event.code == "CLICK")
			{
				var callback:Function = null;

				if (event.level == "0") callback = _callback1;
				else if (event.level == "1") callback = _callback2;

				_callback1 = null;
				_callback2 = null;

				if (callback != null) callback();
			}
		}
	}
}