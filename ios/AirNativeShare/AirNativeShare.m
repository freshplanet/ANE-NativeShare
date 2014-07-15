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

@implementation AirNativeShare

@end


#pragma mark - C interface

DEFINE_ANE_FUNCTION(AirNativeShareShowShare)
{
    CustomText* caption = [[CustomText alloc] initWithFREObject:argv[0]];
    CustomLink* link = nil;
    UIImage*    image = nil;

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
                NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/test.jpg"];
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

    
    
    
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [rootViewController presentViewController:activityController animated:YES completion:nil];
    
    return nil;
}


#pragma mark - ANE setup

void AirNativeShareContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 1;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "AirNativeShareShowShare";
    func[0].functionData = NULL;
    func[0].function = &AirNativeShareShowShare;
    
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