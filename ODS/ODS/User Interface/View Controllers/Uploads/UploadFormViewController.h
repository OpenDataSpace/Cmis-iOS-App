//
//  UploadFormViewController.h
//  ODS
//
//  Created by bdt on 9/21/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomTableViewController.h"
#import "UploadInfo.h"
#import "ModalViewControllerProtocol.h"
#import "UploadsManager.h"

@interface UploadFormViewController : CustomTableViewController <
        ModalViewControllerProtocol,
        UITextFieldDelegate,
        AVAudioPlayerDelegate,
        AVAudioRecorderDelegate>
@property (nonatomic, strong) UploadInfo        *uploadInfo;
@property (nonatomic, strong) NSArray           *multiUploadItems;
@property (nonatomic, assign) UploadFormType    uploadType;
@property (nonatomic, copy) NSString            *selectedAccountUUID;
@property (nonatomic, copy) NSString            *tenantID;
@property (nonatomic, copy) NSString            *fileName;

@property (nonatomic, assign) BOOL  presentedAsModal;

- (void) createUpoadSingleItemForm:(UploadInfo*) info uploadType:(UploadFormType) type;
- (void) createUploadMultiItemsForm:(NSArray*) uploadItems uploadType:(UploadFormType) type;
@end
