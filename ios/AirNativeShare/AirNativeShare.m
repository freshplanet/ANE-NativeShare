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

#import "AirNativeShare.h"
#import "Constants.h"
#import "CustomText.h"

@interface AirNativeShare ()
    @property (nonatomic, readonly) FREContext context;
@end

@implementation AirNativeShare

- (instancetype)initWithContext:(FREContext)extensionContext {
    
    if ((self = [super init])) {
        
        _context = extensionContext;
    }
    
    return self;
}

- (void) sendLog:(NSString*)log {
    [self sendEvent:@"log" level:log];
}

- (void) sendEvent:(NSString*)code {
    [self sendEvent:code level:@""];
}

- (void) sendEvent:(NSString*)code level:(NSString*)level {
    FREDispatchStatusEventAsync(_context, (const uint8_t*)[code UTF8String], (const uint8_t*)[level UTF8String]);
}
@end

AirNativeShare* GetAirNativeShareContextNativeData(FREContext context) {
    
    CFTypeRef controller;
    FREGetContextNativeData(context, (void**)&controller);
    return (__bridge AirNativeShare*)controller;
}

DEFINE_ANE_FUNCTION(showShareDialog) {
    
    AirNativeShare* controller = GetAirNativeShareContextNativeData(context);
    
    if (!controller)
        return AirNativeShare_FPANE_CreateError(@"context's AirNativeShare is null", 0);
    
    
    @try {
    
        NSMutableArray *dataToShare = [[NSMutableArray alloc] init];
        NSArray *rawStringsToShare = AirNativeShare_FPANE_FREObjectToNSArrayOfNSString(argv[0]);
        for (NSString *stringToShare in rawStringsToShare) {
            
            if ([stringToShare containsString:@"http://"] || [stringToShare containsString:@"https://"]) {
                [dataToShare addObject:[NSURL URLWithString:stringToShare]];
            }
            else {
                [dataToShare addObject:stringToShare];
            }
            
        }

        NSArray *imagesToShare = AirNativeShare_FPANE_FREObjectToNSArrayOfUIImage(argv[1]);
        if (imagesToShare.count > 0) {
            [dataToShare addObjectsFromArray:imagesToShare];
        }
        
        [controller sendLog:[@"0 Sharing now... : " stringByAppendingString:@""]];
        //UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            
            [controller sendLog:[@"is an iPad... : " stringByAppendingString:@""]];

            activityViewController.popoverPresentationController.sourceView = [[[[UIApplication sharedApplication] delegate] window] rootViewController].view;
               
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(0,20, 0, 0);
            
            activityViewController.popoverPresentationController.permittedArrowDirections = NO;
            

        }
        
        [activityViewController setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
           
            
            if (completed) {
                [controller sendEvent:kAirNativeShareEvent_didShare level:activityType];
            }
            else {
                [controller sendEvent:kAirNativeShareEvent_cancelled];
            }
            
        }];
        [rootViewController presentViewController:activityViewController animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to share : " stringByAppendingString:exception.reason]];
    }
    
    
    return nil;
}

DEFINE_ANE_FUNCTION(showShareWithCustomTexts) {
    
    AirNativeShare* controller = GetAirNativeShareContextNativeData(context);
    
    if (!controller)
        return AirNativeShare_FPANE_CreateError(@"context's AirNativeShare is null", 0);
    
    
    @try {
        
        CustomText* caption = [[CustomText alloc] initWithFREObject:argv[0]];
        NSString* urlString = AirNativeShare_FPANE_FREObjectToNSString(argv[1]);
        NSURL* url = nil;
        if (![urlString isEqualToString:@""]) {
            url = [NSURL URLWithString:urlString];
        }
        UIImage* image = argc > 2 ? AirNativeShare_FPANE_FREBitmapDataToUIImage(argv[2]) : nil;
        
        NSMutableArray *dataToShare = [[NSMutableArray alloc] init];
        [dataToShare addObject:caption];
        if(url != nil) {
            [dataToShare addObject:url];
        }
        if(image != nil) {
            [dataToShare addObject:image];
        }
        
        
        [controller sendLog:[@"Custom sharing now... : " stringByAppendingString:@""]];
        //UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            
            activityViewController.popoverPresentationController.sourceView = [[[[UIApplication sharedApplication] delegate] window] rootViewController].view;
            
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(0,20, 0, 0);

            activityViewController.popoverPresentationController.permittedArrowDirections = NO;
        }
        
        [activityViewController setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
            if (completed) {
                [controller sendEvent:kAirNativeShareEvent_didShare level:activityType];
            }
            else {
                [controller sendEvent:kAirNativeShareEvent_cancelled];
            }
            
        }];
        [rootViewController presentViewController:activityViewController animated:true completion:nil];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to share : " stringByAppendingString:exception.reason]];
    }
    
    
    return nil;
}

#pragma mark - ANE setup

void AirNativeShareContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                 uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    AirNativeShare* controller = [[AirNativeShare alloc] initWithContext:ctx];
    FRESetContextNativeData(ctx, (void*)CFBridgingRetain(controller));
    
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(showShareDialog, NULL),
        MAP_FUNCTION(showShareWithCustomTexts, NULL),
    };
    
    *numFunctionsToTest = sizeof(functions) / sizeof(FRENamedFunction);
    *functionsToSet = functions;
    
}

void AirNativeShareContextFinalizer(FREContext ctx) {
    CFTypeRef controller;
    FREGetContextNativeData(ctx, (void **)&controller);
    CFBridgingRelease(controller);
}

void AirNativeShareInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AirNativeShareContextInitializer;
    *ctxFinalizerToSet = &AirNativeShareContextFinalizer;
}

void AirNativeShareFinalizer(void *extData) {}
