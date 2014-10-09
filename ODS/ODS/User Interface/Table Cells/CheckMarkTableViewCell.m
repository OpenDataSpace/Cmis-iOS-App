//
//  CheckMarkTableViewCell.m
//  ODS
//
//  Created by bdt on 9/23/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CheckMarkTableViewCell.h"

@implementation CheckMarkTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setSelectedIndex:(NSInteger)selectedIndex {
    [self.detailTextLabel setText:[self.checkOptions objectAtIndex:selectedIndex]];
}

@end
