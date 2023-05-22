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

package com.freshplanet.ane.AirNativeShare.events {
	import flash.events.Event;

	public class AirNativeShareEvent extends Event {

		/**
		 * Supported on iOS only
		 */
		public static const DID_SHARE:String = "AirNativeShareEvent_didShare";
		/**
		 * Supported on iOS only
		 */
		public static const CANCELLED:String = "AirNativeShareEvent_cancelled";
		public static const DENIED:String = "AirNativeShareEvent_denied";

		private var _activityType:String;

		public function get activityType():String {
			return _activityType;
		}

		public function AirNativeShareEvent(type:String, activityType:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_activityType = activityType;

		}
	}
}