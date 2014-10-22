//
//  FailedDownloadsViewController.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"
@class DownloadInfo;

@interface FailedDownloadsViewController : CustomTableViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) NSMutableArray *failedDownloads;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) DownloadInfo *downloadToDismiss;
@end
