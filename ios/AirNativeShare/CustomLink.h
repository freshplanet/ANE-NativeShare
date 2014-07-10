//
//  CustomLink.h
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/9/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomLink : NSURL

- (id) initWithFREObject:(FREObject)object andURLPath:(NSString*)urlPath;

@end
