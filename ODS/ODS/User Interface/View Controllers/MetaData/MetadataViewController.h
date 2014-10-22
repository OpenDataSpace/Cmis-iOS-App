//
//  MetadataViewController.h
//  ODS
//
//  Created by bdt on 9/21/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"

@interface MetadataViewController : CustomTableViewController
@property (nonatomic, strong) CMISObject    *cmisObject;
@property (nonatomic, copy) NSString        *selectedAccountUUID;
@property (nonatomic, copy) NSString        *repositoryID;

- (id)initWithStyle:(UITableViewStyle)style cmisObject:(CMISObject *)cmisObj accountUUID:(NSString *)uuid repositoryID:(NSString*) repoId;
@end
