//
//  PhotoTableViewCell.h
//  ODS
//
//  Created by bdt on 9/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel        *lblTitle;
@property (nonatomic, weak) IBOutlet UIImageView    *imgThumbnal;
@end
