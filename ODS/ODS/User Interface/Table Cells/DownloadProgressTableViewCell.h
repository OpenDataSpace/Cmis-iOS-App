//
//  DownloadProgressTableViewCell.h
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadInfo;

extern NSString * const kDownloadProgressCellIdentifier;

@interface DownloadProgressTableViewCell : UITableViewCell <UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet    UILabel     *labelFileName;
@property (nonatomic, weak) IBOutlet    UILabel     *labelDownloadInfo;
@property (nonatomic, weak) IBOutlet    UILabel     *labelDownloadStatus;
@property (nonatomic, weak) IBOutlet    UIImageView *imgFileIcon;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, strong) DownloadInfo *downloadInfo;
@end
