//
//  CustomLink.m
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/9/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import "CustomLink.h"
@interface CustomLink ()
{
}
@property(nonatomic, retain) NSString *defaultLink;
@property(nonatomic, retain) NSString *messageLink;
@property(nonatomic, retain) NSString *mailLink;
@property(nonatomic, retain) NSString *facebookLink;
@property(nonatomic, retain) NSString *flickrLink;
@property(nonatomic, retain) NSString *vimeoLink;
@property(nonatomic, retain) NSString *weiboLink;
@property(nonatomic, retain) NSString *twitterLink;
@property(nonatomic, retain) NSString *pinterestImageLink;
@end

@implementation CustomLink

- (id) initWithFREObject:(FREObject)object andURLPath:(NSString *)urlPath;
{
    if (urlPath == nil)
    {
        return nil;
    }
    if ([self initWithString:urlPath])
    {
        self.defaultLink = [self getPropertyFromObject:object withName:(const uint8_t*)"defaultLink"];
        self.messageLink = [self getPropertyFromObject:object withName:(const uint8_t*)"messageLink"];
        self.mailLink = [self getPropertyFromObject:object withName:(const uint8_t*)"mailLink"];
        self.facebookLink = [self getPropertyFromObject:object withName:(const uint8_t*)"facebookLink"];
        self.flickrLink = [self getPropertyFromObject:object withName:(const uint8_t*)"flickrLink"];
        self.vimeoLink = [self getPropertyFromObject:object withName:(const uint8_t*)"vimeoLink"];
        self.weiboLink = [self getPropertyFromObject:object withName:(const uint8_t*)"weiboLink"];
        self.twitterLink = [self getPropertyFromObject:object withName:(const uint8_t*)"twitterLink"];
        self.pinterestImageLink = [self getPropertyFromObject:object withName:(const uint8_t*)"pinterestImageLink"];
    }
    return self;
}


- (NSString*) getPropertyFromObject:(FREObject)object withName:(const uint8_t*)name
{
    FREObject   propertyValue;
    FREObject   exception;
    uint32_t    string1Length;
    const uint8_t *string1;
    
    if (FREGetObjectProperty(object, name, &propertyValue, &exception) == FRE_OK)
    {
        FREGetObjectAsUTF8(propertyValue, &string1Length, &string1);
        return[NSString stringWithUTF8String:(char*)string1];
    } else
    {
        NSLog(@"couldn't get property");
        return nil;
    }
    
}


- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    NSLog(@"item for type %@", activityType);
    if (activityType == UIActivityTypeMessage)
    {
        return [NSURL URLWithString:self.messageLink];
    }
    if (activityType == UIActivityTypeMail)
    {
        return [NSURL URLWithString:self.mailLink];
    }
    if (activityType == UIActivityTypePostToFacebook)
    {
        return [NSURL URLWithString:self.facebookLink];
    }
    if (activityType == UIActivityTypePostToFlickr)
    {
        return [NSURL URLWithString:self.flickrLink];
    }
    if (activityType == UIActivityTypePostToVimeo)
    {
        return [NSURL URLWithString:self.vimeoLink];
    }
    if (activityType == UIActivityTypePostToTencentWeibo)
    {
        return [NSURL URLWithString:self.weiboLink];
    }
    if (activityType == UIActivityTypePostToWeibo)
    {
        return [NSURL URLWithString:self.weiboLink];
    }
    if (activityType == UIActivityTypePostToTwitter)
    {
        return [NSURL URLWithString:self.twitterLink];
    }
    if ([activityType isEqualToString: @"com.nshipster.activity.Mustachify"] && self.pinterestImageLink)
    {
        return [NSURL URLWithString:self.pinterestImageLink];
    }
    
    return nil;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return [NSURL URLWithString:self.defaultLink]; }

@end
