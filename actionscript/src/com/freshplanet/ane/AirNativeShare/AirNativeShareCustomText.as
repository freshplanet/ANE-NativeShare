/**
 * Created by Mateo Kozomara (mateo.kozomara@gmail.com) on 04/08/2017.
 */
package com.freshplanet.ane.AirNativeShare {
public class AirNativeShareCustomText {

	public var defaultText:String;
	public var twitterText:String;
	public var messageText:String;
	public var mailText:String;
	public var facebookText:String;
	public var flickrText:String;
	public var vimeoText:String;

	public function AirNativeShareCustomText(defaultText:String = "", twitterText:String = "", messageText:String = "", mailText:String = "", facebookText:String = "", flickrText:String = "", vimeoText:String = "") {
		this.defaultText = defaultText;
		this.twitterText = twitterText == "" ? defaultText : twitterText;
		this.messageText = messageText == "" ? defaultText : messageText;
		this.mailText = mailText == "" ? defaultText : mailText;
		this.facebookText = facebookText == "" ? defaultText : facebookText;
		this.flickrText = flickrText == "" ? defaultText : flickrText;
		this.vimeoText = vimeoText == "" ? defaultText : vimeoText;
	}
}
}
