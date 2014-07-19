package com.freshplanet.ane.AirNativeShare
{
	import flash.events.Event;

	public class AirNativeShareEvent extends Event
	{

		public static const SHARED:String = "NATIVE_SHARE_SUCCESS";


		private var _activityType:String;

		public function get activityType():String
		{
			return _activityType;
		}

		public function AirNativeShareEvent(type:String, activityType:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_activityType = activityType;
			super(type, bubbles, cancelable);
		}
	}
}