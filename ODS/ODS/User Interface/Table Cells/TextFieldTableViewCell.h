//
//  TextFieldTableViewCell.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"

@interface TextFieldTableViewCell : CustomTableViewCell

@property (nonatomic, weak) IBOutlet UILabel        *lblTitle;
@property (nonatomic, weak) IBOutlet UITextField    *textField;

@end
