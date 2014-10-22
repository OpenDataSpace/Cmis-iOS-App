//
//  ChooserFolderViewController.h
//  ODS
//
//  Created by bdt on 10/19/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"

extern NSString * const  kMoveTargetTypeRepo;
extern NSString * const  kMoveTargetTypeFolder;

@protocol ChooserFolderDelegate <NSObject>
@optional
- (void) selectedItem:(CMISFolder*) selectedItem repositoryID:(NSString*) repoID;
@end

@interface ChooserFolderViewController : CustomTableViewController

@property (nonatomic, copy) NSString *viewTitle;
@property (nonatomic, copy) NSString *selectedAccountUUID;
@property (nonatomic, strong) NSArray *folderItems;

@property (nonatomic, copy) NSString    *itemType;  //repo or folder

@property (nonatomic, copy) NSString *tenantID;
@property (nonatomic, copy) NSString *repositoryID;
@property (nonatomic, strong) id parentItem;

@property (nonatomic, assign) id <ChooserFolderDelegate> selectedDelegate;


- (id)initWithAccountUUID:(NSString *)uuid;
@end
