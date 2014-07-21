//
//  CustomPinterestActivity.m
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/17/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import "CustomPinterestActivity.h"
#import "CustomImage.h"

NSString * const FPPinterestActivityType = @"com.freshplanet.activity.CustomPinterestActivity";

@implementation CustomPinterestActivity

@synthesize imageUrl, sourceUrl, description;

static NSString* pinterestClientId = nil;
static NSString* pinterestSuffix = nil;

+(void)initWithClientId:(NSString*)clientId suffix:(NSString*)suffixId
{
    pinterestClientId = clientId;
    pinterestSuffix = suffixId;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}



- (instancetype) init {
    if (self = [super init]) {
        // Yay! Pinterest is funky
        NSString *clientId = [NSMutableString stringWithString:@"1431665"];
        [clientId performSelector:NSSelectorFromString(@"retain")];
		self.pinterest = [[Pinterest alloc] initWithClientId: clientId];
    }
    return self;
}

- (NSString *)activityType {
    return FPPinterestActivityType;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Pinterest", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"instagram"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {    
    if (pinterestClientId == nil)
    {
        return NO;
    }
    
    if (!self.pinterest)
    {
        return NO;
    }
    
	if ([self.pinterest canPinWithSDK]) {
		for (id item in activityItems) {
            NSLog(@"%@", item);
			if ([item isKindOfClass:[CustomImage class]]) {
				NSString* myImageUrl = ((CustomImage*) item).imageUrl;
                if (myImageUrl != nil)
                {
                    NSURL *url = [NSURL URLWithString:myImageUrl];
                    NSLog(@"%@", url);
                    NSLog(@"url path extension %@", url.pathExtension);
                    if (!url.isFileURL && ([url.pathExtension isEqualToString:@"jpeg"] ||
                                           [url.pathExtension isEqualToString:@"png"]  ||
                                           [url.pathExtension isEqualToString:@"jpg"]  ))
                    {
                        return YES;
                    }

                } else
                {
                    NSLog(@"image Url is null");
                }
			}
		}
	}
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"preparing item");
    for (id item in activityItems) {
        if ([item isKindOfClass:[CustomImage class]]) {
            NSString* myImageUrl = ((CustomImage*) item).imageUrl;
            NSString* mySourceUrl = ((CustomImage*) item).sourceUrl;
            self.imageUrl = [NSURL URLWithString:myImageUrl];
            self.sourceUrl = [NSURL URLWithString:mySourceUrl];
            NSLog(@"NSURL detected %@", self.imageUrl);
            
        } else if ([item isKindOfClass:[NSString class]])
        {
            self.description = item;
        }
        else NSLog(@"Unknown item type %@", item);
    }
    if (self.description == nil)
    {
        NSLog(@"no description");
        self.description = @"";
    }

}


- (void)performActivity
{

//    NSString *sourcePath = @"http://www.travelpop.net/play";//pinterestSiteUrl != nil ? pinterestSiteUrl : @"http://www.google.com";
    if (description == nil) {
        description = @" ";
    }
    @try {
        if ([self.pinterest canPinWithSDK])
        {
            [self.pinterest createPinWithImageURL:imageUrl sourceURL:[sourceUrl copy] description:description];
        } else
        {
            NSLog(@"Cannot create Pin");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }

    [self activityDidFinish:YES];
}


@end
