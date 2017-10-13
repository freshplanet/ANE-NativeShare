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
#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import <UIKit/UIKit.h>

#define DEFINE_ANE_FUNCTION(fn) FREObject fn(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }
#define ROOT_VIEW_CONTROLLER [[[UIApplication sharedApplication] keyWindow] rootViewController]

void AirNativeShare_FPANE_DispatchEvent(FREContext context, NSString* eventName);
void AirNativeShare_FPANE_DispatchEventWithInfo(FREContext context, NSString* eventName, NSString* eventInfo);
void AirNativeShare_FPANE_Log(FREContext context, NSString* message);

NSString* AirNativeShare_FPANE_FREObjectToNSString(FREObject object);
NSArray* AirNativeShare_FPANE_FREObjectToNSArrayOfNSString(FREObject object);
NSDictionary* AirNativeShare_FPANE_FREObjectsToNSDictionaryOfNSString(FREObject keys, FREObject values);
BOOL AirNativeShare_FPANE_FREObjectToBool(FREObject object);
NSInteger AirNativeShare_FPANE_FREObjectToInt(FREObject object);
double AirNativeShare_FPANE_FREObjectToDouble(FREObject object);

FREObject AirNativeShare_FPANE_BOOLToFREObject(BOOL boolean);
FREObject AirNativeShare_FPANE_IntToFREObject(NSInteger i);
FREObject AirNativeShare_FPANE_DoubleToFREObject(double d);
FREObject AirNativeShare_FPANE_NSStringToFREObject(NSString* string);
FREObject AirNativeShare_FPANE_CreateError(NSString* error, NSInteger* id);

UIImage* AirNativeShare_FPANE_FREBitmapDataToUIImage(FREObject object);
NSArray* AirNativeShare_FPANE_FREObjectToNSArrayOfUIImage(FREObject object);
