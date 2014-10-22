//
//  ActiveDownloadsViewController.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"
#import "DownloadManager.h"
#import "DownloadInfo.h"

@interface ActiveDownloadsViewController : CustomTableViewController <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *activeDownloads;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIAlertView *alertView;
@end
