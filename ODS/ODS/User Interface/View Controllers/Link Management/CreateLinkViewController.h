//
//  CreateLinkViewController.h
//  ODS
//
//  Created by bdt on 10/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"
#import "DateInputTableViewCell.h"

@class CreateLinkViewController;

@protocol CreateLinkRequestDelegate <NSObject>
@optional
- (void)createLink:(CreateLinkViewController *)createLink succeededForName:(NSString *)linkName;
- (void)createLink:(CreateLinkViewController *)createLink failedForName:(NSString *)linkName;
- (void)createLinkCancelled:(CreateLinkViewController *)createLink;
@end

@interface CreateLinkViewController : CustomTableViewController <DateInputDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, assign) id<CreateLinkRequestDelegate> delegate;
@property (nonatomic, strong) UIBarButtonItem *createButton;
@property (nonatomic, strong) CMISObject *repositoryItem;
@property (nonatomic, copy) NSString *accountUUID;
@property (nonatomic, strong) CMISFolder *parentItem;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, copy) NSString *viewTitle;

- (id)initWithRepositoryItem:(CMISObject *)repoItem parentItem:(CMISFolder*) parentItem accountUUID:(NSString *)accountUUID;
@end
