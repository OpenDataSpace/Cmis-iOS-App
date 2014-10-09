//
//  CheckMarkTableViewCell.h
//  ODS
//
//  Created by bdt on 9/23/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"

@interface CheckMarkTableViewCell : CustomTableViewCell
@property (nonatomic, strong)   NSArray     *checkOptions;
@property (nonatomic, assign)   NSInteger   selectedIndex;
@end
