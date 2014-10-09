//
//  PhotoTableViewCell.m
//  ODS
//
//  Created by bdt on 9/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "PhotoTableViewCell.h"

@implementation PhotoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    if (IS_IPAD) {
        self.imgThumbnal.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    }else {
        self.imgThumbnal.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    [self.imgThumbnal setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
