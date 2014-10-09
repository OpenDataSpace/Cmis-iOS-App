//
//  RepositoriesViewController.h
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"
#import "CMISSessionParameters.h"

@interface RepositoriesViewController : CustomTableViewController
@property (nonatomic, copy) NSString        *viewTitle;
@property (nonatomic, copy) NSString        *selectedAccountUUID;
@property (nonatomic, strong) NSArray       *repositories;
@property (nonatomic, strong) CMISSessionParameters *sessionParameters;

@end
