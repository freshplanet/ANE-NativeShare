//
//  CustomPinterestActivity.m
//  AirNativeShare
//
//  Created by Thibaut Crenn on 7/17/14.
//  Copyright (c) 2014 FreshPlanet. All rights reserved.
//

#import "CustomPinterestActivity.h"

@implementation CustomPinterestActivity

@synthesize imageUrl, sourceUrl, description;

static NSString * const FPPinterestActivityType = @"com.freshplanet.activity.CustomPinterestActivity";
static NSString* pinterestClientId = nil;
static NSString* pinterestSuffix = nil;
static NSString* pinterestSiteUrl = nil;

+(void)initWithClientId:(NSString*)clientId suffix:(NSString*)suffixId andBaseSiteUrl:(NSString*)siteUrl;
{
    pinterestClientId = clientId;
    pinterestSuffix = suffixId;
    pinterestSiteUrl = siteUrl;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}




- (instancetype) init {
    if (self = [super init]) {
		self.pinterest = [[Pinterest alloc] initWithClientId: pinterestClientId];
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
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIImage imageNamed:@"instagram"];
    } else {
        return [UIImage imageNamed:@"instagram"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {    
    if (pinterestClientId == nil)
    {
        return NO;
    }
    
    if (!self.pinterest)
    {
        NSLog(@"no pinterest");
        return NO;
    }
    
	if ([self.pinterest canPinWithSDK]) {
		for (id item in activityItems) {
			if ([item isKindOfClass:[NSURL class]]) {
				NSURL* url = item;
                NSLog(@"%@", url);
                NSLog(@"url path extension %@", url.pathExtension);
				if (!url.isFileURL && ([url.pathExtension isEqualToString:@"jpeg"] ||
                                       [url.pathExtension isEqualToString:@"png"]  ||
                                       [url.pathExtension isEqualToString:@"jpg"]  ))
					return YES;
			}
		}
	}
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"preparing item");
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSURL class]]) {
            self.imageUrl = item;
            NSLog(@"NSURL detected %@", item);
            
        } else if ([item isKindOfClass:[NSString class]])
        {
            self.description = item;
        }
        else NSLog(@"Unknown item type %@", item);
    }

}

static NSArray * HIPMatchingURLsInActivityItems(NSArray *activityItems) {
    for (id item in activityItems) {
        NSLog(@"item detected %@", item);
    }
    return [activityItems filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(id item, __unused NSDictionary *bindings) {
                if ([item isKindOfClass:[NSURL class]] && ![(NSURL *)item isFileURL]) {
                    NSLog(@"&url %@", [(NSURL *)item pathExtension]);
                    return [[(NSURL *)item pathExtension] caseInsensitiveCompare:@"jpg"] == NSOrderedSame ||
                            [[(NSURL *)item pathExtension] caseInsensitiveCompare:@"png"] == NSOrderedSame ||
                            [[(NSURL *)item pathExtension] caseInsensitiveCompare:@"jpeg"] == NSOrderedSame;
                }
                                                           
                return NO;
            }]];
}


- (void)performActivity
{

    NSString *sourcePath = pinterestSiteUrl ? pinterestSiteUrl : @"http://www.google.com/";
    
    @try {
        if ([self.pinterest canPinWithSDK])
        {
            sourceUrl = [NSURL URLWithString:sourcePath];
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
