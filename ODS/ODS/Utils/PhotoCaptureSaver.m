/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  PhotoCaptureSaver.m
//

#import "PhotoCaptureSaver.h"
#import "FileUtils.h"

NSString * const kDefaultImageExtension = @"jpg";

@implementation PhotoCaptureSaver
@synthesize originalImage = _originalImage;
@synthesize metadata = _metadata;
@synthesize assetURL = _assetURL;
@synthesize locationManager = _locationManager;
@synthesize userLocation = _userLocation;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_originalImage release];
    [_metadata release];
    [_assetURL release];
    [_locationManager release];
    [_userLocation release];
    [super dealloc];
}

- (id)initWithPickerInfo:(NSDictionary *)pickerInfo andDelegate:(id<PhotoCaptureSaverDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        [self setDelegate:delegate];
        [self setOriginalImage:[pickerInfo objectForKey:UIImagePickerControllerOriginalImage]];
        [self setMetadata:[pickerInfo objectForKey:UIImagePickerControllerMediaMetadata]];
        
        if([CLLocationManager locationServicesEnabled]) {
            [self setLocationManager:[[[CLLocationManager alloc] init] autorelease]];
            [self.locationManager setDelegate:self];
        }
    }
    return self;
}

- (void)startSavingImage
{
    saved = NO;
    if(self.locationManager)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationManager startUpdatingLocation];
            });
    }
    else 
    {
        [self saveImage:nil];
    }
}

- (void)saveImage:(CLLocation *)location
{
    if(saved)
    {
        return;
    }
    
    saved = YES;
    NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionaryWithDictionary:self.metadata];
    if (location) {
        // From http://stackoverflow.com/questions/4043685/problem-in-writing-metadata-to-image
        // Create formatted date
        NSTimeZone      *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDateFormatter *formatter  = [[NSDateFormatter alloc] init]; 
        [formatter setTimeZone:timeZone];
        [formatter setDateFormat:@"HH:mm:ss.SS"];
        
        // Create GPS Dictionary
        NSDictionary *gpsDict   = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:fabs(location.coordinate.latitude)], kCGImagePropertyGPSLatitude
                                   , ((location.coordinate.latitude >= 0) ? @"N" : @"S"), kCGImagePropertyGPSLatitudeRef
                                   , [NSNumber numberWithFloat:fabs(location.coordinate.longitude)], kCGImagePropertyGPSLongitude
                                   , ((location.coordinate.longitude >= 0) ? @"E" : @"W"), kCGImagePropertyGPSLongitudeRef
                                   , [formatter stringFromDate:[location timestamp]], kCGImagePropertyGPSTimeStamp
                                   , nil];
        
        // Memory Management
        [formatter release];
        
        // Set GPS Dictionary to be part of media Metadata
        [mutableMetadata setValue:gpsDict forKey:(NSString *)kCGImagePropertyGPSDictionary];
    } 
    
    ODSLogTrace(@"Metadata dictionay that will be embedded into the photo properties: %@", mutableMetadata);
    ALAssetsLibraryWriteImageCompletionBlock completeBlock = ^(NSURL *assetURL, NSError *error) 
    {
        BOOL success = NO;
        
        if(!location)
        {
            // We need to save the image into a file with the metadata in the temp folder
            // when location is not enabled, we need to assume the access to the AssetsLibrary will be denied
            NSString *tempImageName = [[NSString generateUUID] stringByAppendingPathExtension:kDefaultImageExtension];
            NSString *tempImagePath = [FileUtils pathToTempFile:tempImageName];
            success = [self writeImage:self.originalImage toFile:tempImagePath metadata:mutableMetadata];
            
            if(success)
            {
                [self setAssetURL:[NSURL fileURLWithPath:tempImagePath]];
                ODSLogDebug(@"Saved image url: %@", self.assetURL);
                if([self.delegate respondsToSelector:@selector(photoCaptureSaver:didFinishSavingWithURL:)])
                {
                    [self.delegate photoCaptureSaver:self didFinishSavingWithURL:self.assetURL];
                }

            }
        } 
        else if(!error)
        {
            success = YES;
            //get asset url
            [self setAssetURL:assetURL];
            ODSLogDebug(@"Saved image url: %@", assetURL);
            if([self.delegate respondsToSelector:@selector(photoCaptureSaver:didFinishSavingWithAssetURL:)])
            {
                [self.delegate photoCaptureSaver:self didFinishSavingWithAssetURL:assetURL];
            }
        }
        
        if (!success) {
            if([self.delegate respondsToSelector:@selector(photoCaptureSaver:didFailWithError:)])
            {
                [self.delegate photoCaptureSaver:self didFailWithError:error];
            }
        }
    };
    
    ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
    [library writeImageToSavedPhotosAlbum:[self.originalImage CGImage] 
                                 metadata:mutableMetadata
                          completionBlock:completeBlock];
}


#pragma mark - CLLocationManagerDelegate methods
/* We will only try to retrieve once the location, after that we stop the service
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    ODSLogTrace(@"Location updated with: lat:%f lon:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [self setUserLocation:newLocation];
    [self.locationManager stopUpdatingLocation];
    [self setLocationManager:nil];
    
    [self saveImage:self.userLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    ODSLogTrace(@"Could not fix a user location, the GPS may be disabled or the user denied the current location to the app");
    [self.locationManager stopUpdatingLocation];
    [self setLocationManager:nil];
    
    [self saveImage:nil];
}

- (BOOL)writeImage:(UIImage *)image toFile:(NSString *)imagePath metadata:(NSDictionary *)metadata
{
    // From SO question: http://stackoverflow.com/questions/5125323/problem-setting-exif-data-for-an-image
    NSData *jpegImage = UIImageJPEGRepresentation(image, 1.0);
    CGImageSourceRef  source = CGImageSourceCreateWithData((CFDataRef)jpegImage, NULL);
    CFStringRef UTI = CGImageSourceGetType(source);
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        ODSLogDebug(@"***Could not create image destination ***");
        if (source) 
        {
            CFRelease(source);
        }
        return NO;
    }
    
    CGImageRef imgRef = NULL;

    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) metadata);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        ODSLogDebug(@"***Could not create data from image destination ***");
    }
    else {
        //now we have the data ready to go, so do whatever you want with it
        //here we just write it to disk at the same path we were passed
        [dest_data writeToFile:imagePath atomically:YES];
    }
    
    //cleanup
    
    CFRelease(destination);
    CFRelease(source);
    if (imgRef != NULL)
        CFRelease(imgRef);
    
    return success;
}
@end
