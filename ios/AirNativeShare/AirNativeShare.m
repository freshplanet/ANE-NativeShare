//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//////////////////////////////////////////////////////////////////////////////////////

#import "AirNativeShare.h"
#import "CustomText.h"
#import "CustomLink.h"
#import "CustomPinterestActivity.h"
#import "CustomInstagramActivity.h"

@implementation AirNativeShare

@synthesize documentController;

+(id) sharedInstance {
    static id sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}



@end


#pragma mark - C interface

DEFINE_ANE_FUNCTION(AirNativeShareShowShare)
{
    CustomText* caption = [[CustomText alloc] initWithFREObject:argv[0]];
    CustomLink* link = nil;
    UIImage*    image = nil;
    NSString *imagePath = nil;
    
    if (argc > 0)
    {
        FREObject   propertyValue;
        FREObject   exception;
        uint32_t    string1Length;
        const uint8_t *string1;
        if (FREGetObjectProperty(argv[0], (const uint8_t*)"defaultLink", &propertyValue, &exception) == FRE_OK)
        {
            NSLog(@"got link");
            FREGetObjectAsUTF8(propertyValue, &string1Length, &string1);
            link = [[CustomLink alloc] initWithFREObject:argv[0] andURLPath:[NSString stringWithUTF8String:(char*)string1]];
        } else
        {
            NSLog(@"couldn't get link");
        }
        
        if (argc > 1)
        {
            NSLog(@"got bitmapData");
            FREBitmapData bitmapData;
            if (FREAcquireBitmapData(argv[1], &bitmapData) == FRE_OK)
            {
                
                // make data provider from buffer
                CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (bitmapData.width * bitmapData.height * 4), NULL);
                
                // set up for CGImage creation
                int                     bitsPerComponent    = 8;
                int                     bitsPerPixel        = 32;
                int                     bytesPerRow         = 4 * bitmapData.width;
                CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
                CGBitmapInfo            bitmapInfo;
                
                if( bitmapData.hasAlpha )
                {
                    if( bitmapData.isPremultiplied )
                        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
                    else
                        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
                }
                else
                {
                    bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
                }
                
                CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
                CGImageRef imageRef           = CGImageCreate(bitmapData.width, bitmapData.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
                
                // make UIImage from CGImage
                image = [UIImage imageWithCGImage:imageRef];
                
                FREReleaseBitmapData(argv[1]);
                
                NSData *imageData= UIImageJPEGRepresentation(image,0.0);
                imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/insta.igo"];
                [imageData writeToFile:imagePath atomically:YES];

                
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else
        {
            NSLog(@"couldn't get bitmapData");
        }

    }
    

    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    if (caption)
    {
        [activityItems addObject:caption];
    }
    
    NSLog(@"caption added");
    
    if (link != nil)
    {
        [activityItems addObject:link];
    } else
    {
        NSLog(@"link is null");
    }
    
    NSLog(@"link added");
    
    if (image != nil)
    {
        [activityItems addObject:image];
        NSLog(@"image added");

    } else
    {
        NSLog(@"image is null");

    }

    NSLog(@"showing root");

    
    
    CustomPinterestActivity *pinActivity = [[CustomPinterestActivity alloc] init];
    CustomInstagramActivity *instagramActivity = [[CustomInstagramActivity alloc] init];
    
    
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[instagramActivity, pinActivity]];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        
        if (completed && [activityType isEqualToString:@"com.freshplanet.activity.CustomInstagramActivity"])
        {
            
            UIDocumentInteractionController * documentController;
            documentController = [UIDocumentInteractionController interactionControllerWithURL: [NSURL fileURLWithPath:imagePath]];

            ((AirNativeShare*)[AirNativeShare sharedInstance]).documentController = documentController;
            
            
            // setting specific param
            documentController.UTI = @"com.instagram.exclusivegram";
            if (caption != nil)
            {
                documentController.annotation = [NSDictionary dictionaryWithObject:caption forKey:@"InstagramCaption"];
            }
            
            // Present the tweet composition view controller modally.
            id delegate = [[UIApplication sharedApplication] delegate];
            
            documentController.delegate = delegate;
            
            UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
            
            [documentController presentOpenInMenuFromRect:CGRectMake(0, 0, 100, 100) inView:rootView animated:YES];

        }
        
    }];
    
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        UIView *view = rootViewController.view;
        [popup presentPopoverFromRect:CGRectMake(view.frame.size.width/2 - 50, view.frame.size.height/2 - 50, 100, 100) inView:view permittedArrowDirections:0 animated:YES];

        
    } else {
        // present modally
        [rootViewController presentViewController:activityController animated:YES completion:nil];
    }

    
    
    return nil;
}


DEFINE_ANE_FUNCTION(AirNativeShareInitPinterest)
{
    NSString * pinterestClientId = FPANE_FREObjectToNSString(argv[0]);
    NSString * pinterestSuffix = nil;
    NSString * pinterestSiteUrl = FPANE_FREObjectToNSString(argv[1]);
    if (argc > 2)
    {
        pinterestSuffix = FPANE_FREObjectToNSString(argv[2]);
    }
    
    [CustomPinterestActivity initWithClientId:pinterestClientId suffix:pinterestSuffix andBaseSiteUrl:pinterestSiteUrl];

    return nil;
}

DEFINE_ANE_FUNCTION(AirNativeShareIsSupported)
{
    NSLog(@"check if supported");
    BOOL isSupported = NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1;
    NSLog(@"is supported");
    return FPANE_BOOLToFREObject(isSupported);
}


#pragma mark - ANE setup

void AirNativeShareContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 3;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "AirNativeShareShowShare";
    func[0].functionData = NULL;
    func[0].function = &AirNativeShareShowShare;
    
    
    func[1].name = (const uint8_t*) "AirNativeShareInitPinterest";
    func[1].functionData = NULL;
    func[1].function = &AirNativeShareInitPinterest;

    
    func[2].name = (const uint8_t*) "AirNativeShareIsSupported";
    func[2].functionData = NULL;
    func[2].function = &AirNativeShareIsSupported;

    *functionsToSet = func;
}

void AirNativeShareContextFinalizer(FREContext ctx) { }

void AirNativeShareInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirNativeShareContextInitializer;
	*ctxFinalizerToSet = &AirNativeShareContextFinalizer;
}

void AirNativeShareFinalizer(void* extData) { }