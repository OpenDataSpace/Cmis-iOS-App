//
//  MoreTableViewCell.h
//  ODS
//
//  Created by bdt on 9/23/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"

@interface MoreTableViewCell : CustomTableViewCell
@property (nonatomic, weak) IBOutlet UILabel        *labelTitle;
@property (nonatomic, weak) IBOutlet UIImageView    *cellIcon;
@property (nonatomic, weak) IBOutlet UIImageView    *statusIcon;
@end
