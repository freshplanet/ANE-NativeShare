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

package com.freshplanet.ane.AirNativeShare;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.freshplanet.ane.AirNativeShare.functions.RequestStoragePermissionFunction;
import com.freshplanet.ane.AirNativeShare.functions.ShareFunction;
import com.freshplanet.ane.AirNativeShare.functions.ShareToStoryFunction;

import java.util.HashMap;
import java.util.Map;

public class AirNativeShareExtensionContext extends FREContext {
	@Override
	public void dispose()
	{
		AirNativeShareExtension.context = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
		
		functions.put("showShareDialog", new ShareFunction());
		functions.put("requestStoragePermission", new RequestStoragePermissionFunction());
		functions.put("shareToStory", new ShareToStoryFunction());
		return functions;
	}


}