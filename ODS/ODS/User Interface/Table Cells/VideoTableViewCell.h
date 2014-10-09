//
//  VideoTableViewCell.h
//  ODS
//
//  Created by bdt on 9/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet    UILabel     *labelTitle;
@property (nonatomic, weak) IBOutlet    UIView      *videoView;
@end
