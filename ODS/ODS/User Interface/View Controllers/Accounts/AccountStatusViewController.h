//
//  AccountStatusViewController.h
//  ODS
//
//  Created by bdt on 9/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"

@class AccountInfo;
@interface AccountStatusViewController : CustomTableViewController
@property (nonatomic, strong) AccountInfo   *acctInfo;
@end
