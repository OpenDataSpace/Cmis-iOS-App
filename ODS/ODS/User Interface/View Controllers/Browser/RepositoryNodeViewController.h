//
//  RepositoryNodeViewController.h
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"
#import "CMISFolder.h"
#import "CreateFolderViewController.h"
#import "AGImagePickerController.h"
#import "PhotoCaptureSaver.h"
#import "DeleteQueueProgressBar.h"
#import "MultiSelectActionsToolbar.h"

@interface RepositoryNodeViewController : CustomTableViewController <
    AGImagePickerControllerDelegate,
    CreateFolderRequestDelegate,
    PhotoCaptureSaverDelegate,
    DeleteQueueDelegate,
    MultiSelectActionsDelegate,
    UIActionSheetDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate>

@property (nonatomic, strong) CMISFolder            *folder;
@property (nonatomic, strong) CMISPagedResult       *pagedFolders;
@property (nonatomic, copy) NSString                *selectedAccountUUID;
@property (nonatomic, copy) NSString                *repositoryIdentifier;

@property (nonatomic, strong) UIActionSheet             *actionSheet;
@property (nonatomic, strong) UIBarButtonItem           *actionSheetSenderControl;
@property (nonatomic, assign) CGRect                    actionSheetSenderRect;
@property (nonatomic, strong) UIPopoverController       *popover;
@property (nonatomic, strong) UIImagePickerController   *imagePickerController;
@property (nonatomic, strong) PhotoCaptureSaver         *photoSaver;

@property (nonatomic, strong) CMISObject                *selectedItem;


@property (nonatomic, strong) MultiSelectActionsToolbar *multiSelectToolbar;
@property (nonatomic, strong) DeleteQueueProgressBar *deleteQueueProgressBar;
@end
