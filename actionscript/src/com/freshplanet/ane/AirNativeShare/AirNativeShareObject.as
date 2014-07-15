package com.freshplanet.ane.AirNativeShare
{
	import flash.display.BitmapData;

	public class AirNativeShareObject
	{
		public var messageText:String;
		public var mailText:String;
		public var facebookText:String;
		public var flickrText:String;
		public var vimeoText:String;
		public var weiboText:String;
		public var twitterText:String;


		public var defaultLink:String = null;
		public var messageLink:String;
		public var mailLink:String;
		public var facebookLink:String;
		public var flickrLink:String;
		public var vimeoLink:String;
		public var weiboLink:String;
		public var twitterLink:String;

		public var bitmapData:BitmapData = null;

		public function AirNativeShareObject()
		{
		}

		public function setDefaultText(value:String):void
		{
			messageText = value;
			mailText = value;
			facebookText = value;
			flickrText = value;
			vimeoText = value;
			weiboText = value;
			twitterText = value;
		}

		public function setDefaultLink(value:String):void
		{
			messageLink = value;
			mailLink = value;
			facebookLink = value;
			flickrLink = value;
			vimeoLink = value;
			weiboLink = value;
			twitterLink = value;
		}
	}
}