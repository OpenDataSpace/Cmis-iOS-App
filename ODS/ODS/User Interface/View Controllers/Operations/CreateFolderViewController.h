//
//  CreateFolderViewController.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

#import "CMISFolder.h"

@class CreateFolderViewController;

@protocol CreateFolderRequestDelegate <NSObject>
@optional
- (void)createFolder:(CreateFolderViewController *)createFolder succeededForName:(NSString *)folderName;
- (void)createFolder:(CreateFolderViewController *)createFolder failedForName:(NSString *)folderName;
- (void)createFolderCancelled:(CreateFolderViewController *)createFolder;
@end

@interface CreateFolderViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<CreateFolderRequestDelegate> delegate;
@property (nonatomic, retain) UIBarButtonItem *createButton;
@property (nonatomic, retain) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSRegularExpression *regexNameValidation;
@property (nonatomic, strong) CMISFolder    *parentFolder;
@property (nonatomic, copy)   NSString      *folderName;
@end
