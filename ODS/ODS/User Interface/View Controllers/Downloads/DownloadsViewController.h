//
//  DownloadsViewController.h
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewController.h"
#import "DocumentFilter.h"
#import "DirectoryWatcher.h"

@class FolderTableViewDataSource;

@interface DownloadsViewController : CustomTableViewController <DirectoryWatcherDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) DirectoryWatcher *dirWatcher;
@property (nonatomic, strong) NSURL *selectedFile;
@property (nonatomic, strong) FolderTableViewDataSource *folderDatasource;
@property (nonatomic, strong) id<DocumentFilter> documentFilter;

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher;
- (void)detailViewControllerChanged:(NSNotification *)notification;
@end
