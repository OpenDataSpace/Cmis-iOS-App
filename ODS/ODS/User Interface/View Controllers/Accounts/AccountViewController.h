//
//  AccountViewController.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"
#import "CheckMarkViewController.h"

@class AccountInfo;

@interface AccountViewController : CustomTableViewController <UITextFieldDelegate, CheckMarkDelegate>
@property (nonatomic, strong) AccountInfo   *acctInfo;

@property (nonatomic, assign) BOOL          isEdit;
@property (nonatomic, assign) BOOL          isNew;
@end
