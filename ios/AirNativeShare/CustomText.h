//
//  CustomText.h
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/9/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import <UIKit/UIKit.h>

@interface CustomText : NSString <UIActivityItemSource>



- (id) initWithFREObject:(FREObject)object;

@end
