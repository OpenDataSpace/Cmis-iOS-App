//
//  UploadProgressTableViewCell.h
//  ODS
//
//  Created by bdt on 10/10/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadInfo.h"

@interface UploadProgressTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet    UILabel     *labelFileName;
@property (nonatomic, weak) IBOutlet    UILabel     *labelUploadStatus;
@property (nonatomic, weak) IBOutlet    UIProgressView  *progressView;
@property (nonatomic, weak) IBOutlet    UIImageView *imgFileIcon;

@property (nonatomic, strong)   UploadInfo  *uploadInfo;
@end
