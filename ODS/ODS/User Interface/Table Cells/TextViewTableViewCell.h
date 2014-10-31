//
//  TextViewTableViewCell.h
//  ODS
//
//  Created by bdt on 10/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewCell.h"

@interface TextViewTableViewCell : CustomTableViewCell
@property (nonatomic, weak) IBOutlet UILabel    *labelTitle;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end
