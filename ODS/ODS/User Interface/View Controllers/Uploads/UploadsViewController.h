//
//  UploadsViewController.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"

@class UploadInfo;
@class UploadProgressTableViewCell;

@interface UploadsViewController : CustomTableViewController <UIPopoverControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UploadInfo *uploadToDismiss;
@property (nonatomic, strong) UploadProgressTableViewCell *uploadToCancel;
@property (nonatomic, strong) UIPopoverController *popover;
@end
