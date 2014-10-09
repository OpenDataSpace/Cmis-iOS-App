//
//  CheckMarkViewController.h
//  ODS
//
//  Created by bdt on 9/23/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckMarkViewController;
@class CheckMarkTableViewCell;

@protocol CheckMarkDelegate <NSObject>

- (void) selectCheckMarkOption:(NSInteger) index withCell:(CheckMarkTableViewCell*) cell;

@end

@interface CheckMarkViewController : UITableViewController
@property (nonatomic, copy) NSString        *viewTitle;
@property (nonatomic, strong) CheckMarkTableViewCell        *checkMarkCell;
@property (nonatomic, strong)   NSArray     *options;
@property (nonatomic, assign)   NSInteger   selectedIndex;
@property (nonatomic, assign)   id <CheckMarkDelegate> checkMarkDelegate;
@end
