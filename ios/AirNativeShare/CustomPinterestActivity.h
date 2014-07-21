//
//  CustomPinterestActivity.h
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/17/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pinterest/Pinterest.h>

extern NSString * const FPPinterestActivityType;

@interface CustomPinterestActivity : UIActivity

+(void)initWithClientId:(NSString*)clientId suffix:(NSString*)suffixId;

@property(nonatomic, retain) NSURL *imageUrl;
@property(nonatomic, retain) NSURL *sourceUrl;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) Pinterest *pinterest;

@end
