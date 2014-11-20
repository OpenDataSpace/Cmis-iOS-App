//
//  RenameQueueProgressBar.h
//  ODS
//
//  Created by bdt on 10/19/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RenameQueueProgressBar;

@protocol RenameQueueDelegate <NSObject>

- (void)renameQueue:(RenameQueueProgressBar *)renameQueueProgressBar completedRename:(id)renamedItem;
@optional
- (void)renameQueueWasCancelled:(RenameQueueProgressBar *)renameQueueProgressBar;

@end

@interface RenameQueueProgressBar : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CMISObject *itemToRename;
@property (nonatomic, copy) NSString *theNewItemName;
@property (nonatomic, strong) UIAlertView *progressAlert;
@property (nonatomic, assign) id<RenameQueueDelegate> delegate;
@property (nonatomic, copy) NSString *progressTitle;
@property (nonatomic, strong) UIActivityIndicatorView *progressView;
@property (nonatomic, copy) NSString *selectedUUID;
@property (nonatomic, copy) NSString *tenantID;

- (void)startRenaming;
- (void)cancel;
+ (RenameQueueProgressBar *)createWithItem:(CMISObject*) item withNewName:(NSString*)newName delegate:(id <RenameQueueDelegate>)del andMessage:(NSString *)message;
@end
