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
package {


import com.freshplanet.ane.AirNativeShare.AirNativeShare;
import com.freshplanet.ane.AirNativeShare.events.AirNativeShareEvent;

import flash.display.BitmapData;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;

import com.freshplanet.ui.ScrollableContainer;
import com.freshplanet.ui.TestBlock;

[SWF(backgroundColor="#057fbc", frameRate='60')]
public class Main extends Sprite {

    public static var stageWidth:Number = 0;
    public static var indent:Number = 0;

    private var _scrollableContainer:ScrollableContainer = null;

    public function Main() {
        this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
    }

    private function _onAddedToStage(event:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        this.stage.align = StageAlign.TOP_LEFT;

        stageWidth = this.stage.stageWidth;
        indent = stage.stageWidth * 0.025;

        _scrollableContainer = new ScrollableContainer(false, true);
        this.addChild(_scrollableContainer);

        if (!AirNativeShare.isSupported) {
            trace("AirFlurry ANE is NOT supported on this platform!");
            return;
        }

	    //supported on ios only
	    AirNativeShare.instance.addEventListener(AirNativeShareEvent.DID_SHARE, onDidShare);
	    //supported on ios only
	    AirNativeShare.instance.addEventListener(AirNativeShareEvent.CANCELLED, onShareCancelled);

        var blocks:Array = [];

        blocks.push(new TestBlock("share text", function():void {
	        AirNativeShare.instance.showShare(["Hello Planet"]);
        }));
        blocks.push(new TestBlock("share url", function():void {
	        AirNativeShare.instance.showShare(["http://freshplanet.com"]);
        }));
	    blocks.push(new TestBlock("share red square image", function():void {
		    AirNativeShare.instance.showShare([new BitmapData(100,100,false, 0xff0000)]);
	    }));
	    blocks.push(new TestBlock("share multiple", function():void {
		    AirNativeShare.instance.showShare(["http://freshplanet.com", new BitmapData(100,100,false, 0xff0000)]);
	    }));


        /**
         * add ui to screen
         */

        var nextY:Number = indent;

        for each (var block:TestBlock in blocks) {

            _scrollableContainer.addChild(block);
            block.y = nextY;
            nextY +=  block.height + indent;
        }
    }

	private function onShareCancelled(event:AirNativeShareEvent):void {
		trace("Share cancelled by the user");
	}

	private function onDidShare(event:AirNativeShareEvent):void {
		trace("Share successful with activityType: ", event.activityType);
	}


}
}
