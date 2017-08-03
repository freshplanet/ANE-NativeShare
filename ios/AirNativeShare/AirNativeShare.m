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
        return FPANE_CreateError(@"context's AirNativeShare is null", 0);
    
    
    @try {
    
        NSMutableArray *dataToShare = [[NSMutableArray alloc] init];
        NSArray *rawStringsToShare = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
        for (NSString *stringToShare in rawStringsToShare) {
            
            if ([stringToShare containsString:@"http://"] || [stringToShare containsString:@"https://"]) {
                [dataToShare addObject:[NSURL URLWithString:stringToShare]];
            }
            else {
                [dataToShare addObject:stringToShare];
            }
            
        }

        NSArray *imagesToShare = FPANE_FREObjectToNSArrayOfUIImage(argv[1]);
        [dataToShare addObjectsFromArray:imagesToShare];
        
        [controller sendLog:[@"Sharing now... : " stringByAppendingString:@""]];
        UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            activityViewController.popoverPresentationController.sourceView = rootViewController.view;
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
        MAP_FUNCTION(showShareDialog, NULL)
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
