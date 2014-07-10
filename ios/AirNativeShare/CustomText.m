//
//  CustomText.m
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/9/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import "CustomText.h"
@interface CustomText ()
{
}
@property(nonatomic, retain) NSString *messageText;
@property(nonatomic, retain) NSString *mailText;
@property(nonatomic, retain) NSString *facebookText;
@property(nonatomic, retain) NSString *flickrText;
@property(nonatomic, retain) NSString *vimeoText;
@property(nonatomic, retain) NSString *weiboText;
@property(nonatomic, retain) NSString *twitterText;

@end

@implementation CustomText

- (id) initWithFREObject:(FREObject)object;
{
    if ([self init])
    {
        self.messageText = [self getPropertyFromObject:object withName:(const uint8_t*)"messageText"];
        self.mailText = [self getPropertyFromObject:object withName:(const uint8_t*)"mailText"];
        self.facebookText = [self getPropertyFromObject:object withName:(const uint8_t*)"facebookText"];
        self.flickrText = [self getPropertyFromObject:object withName:(const uint8_t*)"flickrText"];
        self.vimeoText = [self getPropertyFromObject:object withName:(const uint8_t*)"vimeoText"];
        self.weiboText = [self getPropertyFromObject:object withName:(const uint8_t*)"weiboText"];
        self.twitterText = [self getPropertyFromObject:object withName:(const uint8_t*)"twitterText"];
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
    if (activityType == UIActivityTypeMessage)
    {
        return self.messageText;
    }
    if (activityType == UIActivityTypeMail)
    {
        return self.mailText;
    }
    if (activityType == UIActivityTypePostToFacebook)
    {
        return self.facebookText;
    }
    if (activityType == UIActivityTypePostToFlickr)
    {
        return self.flickrText;
    }
    if (activityType == UIActivityTypePostToVimeo)
    {
        return self.vimeoText;
    }
    if (activityType == UIActivityTypePostToTencentWeibo)
    {
        return self.weiboText;
    }
    if (activityType == UIActivityTypePostToWeibo)
    {
        return self.weiboText;
    }
    if (activityType == UIActivityTypePostToTwitter)
    {
        return self.twitterText;
    }

    return @"";
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

@end
