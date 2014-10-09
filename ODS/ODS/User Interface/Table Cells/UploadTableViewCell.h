//
//  UploadTableViewCell.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UploadInfo;

@interface UploadTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView    *imgIcon;
@property (nonatomic, weak) IBOutlet UILabel        *labelFilename;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIButton       *accessButton;

@property (nonatomic, strong) UploadInfo            *uploadInfo;
@end
