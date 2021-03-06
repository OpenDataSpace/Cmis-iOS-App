//
//  SettingsViewController.h
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"
#import "CheckMarkViewController.h"
#import "DirectoryWatcher.h"

@interface SettingsViewController : CustomTableViewController <
    CheckMarkDelegate,
    DirectoryWatcherDelegate,
    UIAlertViewDelegate,
    UIActionSheetDelegate>

@end
