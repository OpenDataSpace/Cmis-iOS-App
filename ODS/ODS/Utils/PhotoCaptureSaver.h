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
//  PhotoCaptureSaver.h
//
// Helper class that saves an image captured with a UIImagePickerController 
// and saves it to the Camera Roll with the Asset Library.
// It adds the camera EXIF metadata and also queries the Core Location for the user's location
// and embbeds it in the image.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PhotoCaptureSaverDelegate;

@interface PhotoCaptureSaver : NSObject <CLLocationManagerDelegate>
{
    BOOL saved;
}

/*
 Original image returned by the UIImagePickerController
 */
@property (nonatomic, retain) UIImage *originalImage;
/*
 Image metadata returned by the UIImagePickerController
 */
@property (nonatomic, retain) NSDictionary *metadata;
@property (nonatomic, retain) NSURL *assetURL;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, assign) id<PhotoCaptureSaverDelegate> delegate;

- (id)initWithPickerInfo:(NSDictionary *)pickerInfo andDelegate:(id<PhotoCaptureSaverDelegate>)delegate;
- (void)startSavingImage;
@end
                           
/*
 Delegate protocol to handle the success and error callbacks
 */
@protocol PhotoCaptureSaverDelegate <NSObject>
- (void)photoCaptureSaver:(PhotoCaptureSaver *)photoSaver didFinishSavingWithAssetURL:(NSURL *)assetURL;
- (void)photoCaptureSaver:(PhotoCaptureSaver *)photoSaver didFinishSavingWithURL:(NSURL *)imageURL;
@optional
- (void)photoCaptureSaver:(PhotoCaptureSaver *)photoSaver didFailWithError:(NSError *)error;
@end

extern NSString *const kDefaultImageExtension;
