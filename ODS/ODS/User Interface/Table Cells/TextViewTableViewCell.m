//
//  TextViewTableViewCell.m
//  ODS
//
//  Created by bdt on 10/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "TextViewTableViewCell.h"

@implementation TextViewTableViewCell
@synthesize labelTitle = _labelTitle;
@synthesize textView = _textView;

- (void)awakeFromNib {
    // Initialization code
    _textView.layer.borderWidth = 1.0;
    _textView.layer.cornerRadius = 5.0;
    _textView.layer.borderColor = [[UIColor colorWithRed:153.0f/255.0 green:153.0f/255.0 blue:153.0f/255.0 alpha:0.50f] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
