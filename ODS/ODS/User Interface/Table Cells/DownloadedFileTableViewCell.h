//
//  DownloadedFileTableViewCell.h
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadedFileTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet    UILabel     *labelFileName;
@property (nonatomic, weak) IBOutlet    UILabel     *labelFileInfo;
@property (nonatomic, weak) IBOutlet    UIImageView *imgFileIcon;
@end
