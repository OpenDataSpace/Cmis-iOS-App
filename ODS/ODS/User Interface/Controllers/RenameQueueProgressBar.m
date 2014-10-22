//
//  RenameQueueProgressBar.m
//  ODS
//
//  Created by bdt on 10/19/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "RenameQueueProgressBar.h"
#import "CMISObject.h"
#import "CMISUtility.h"
#import "AccountManager.h"
#import "CMISRequest.h"

@interface RenameQueueProgressBar (private)
- (void) loadRenameView;
@end

@implementation RenameQueueProgressBar
@synthesize itemToRename = _itemToRename;
@synthesize delegate = _delegate;
@synthesize progressAlert = _progressAlert;
@synthesize progressTitle = _progressTitle;
@synthesize progressView = _progressView;
@synthesize selectedUUID = _selectedUUID;
@synthesize tenantID = _tenantID;
@synthesize theNewItemName = _theNewItemName;

- (id)initWithItem:(CMISObject *)item withNewName:(NSString*)newName delegate:(id<RenameQueueDelegate>)del andMessage:(NSString *)message
{
    self = [super init];
    if (self)
    {
        self.itemToRename = item;
        self.delegate = del;
        self.progressTitle = message;
        self.theNewItemName = newName;
        
        [self loadRenameView];
    }
    
    return self;
}

#pragma mark - private methods
- (void)loadRenameView
{
    // create a modal alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.progressTitle
                                                    message:NSLocalizedString(@"pleaseWaitMessage", @"Please Wait...")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancelButton", @"Cancel")
                                          otherButtonTitles:nil];
    alert.message = [NSString stringWithFormat: @"%@%@", alert.message, @"\n\n\n\n"];
    self.progressAlert = alert;
    
    
    // create a progress bar and put it in the alert
    UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.progressView = progress;
    [self.progressAlert addSubview:self.progressView];
}

#pragma mark - public methods
- (void) startRenaming {
    [self.progressAlert show];
    [CMISUtility renameWithItem:self.itemToRename newName:self.theNewItemName withCompletionBlock:^(CMISObject *object, NSError *error) {
        [_progressAlert dismissWithClickedButtonIndex:1 animated:NO];
        if (error) {  //TODO:add tips
            ODSLogError(@"%@", error);
        }else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(renameQueue:completedRename:)])
            {
                [self.delegate renameQueue:self completedRename:object];
            }
        }
    }];
}

- (void) cancel {
    [_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - static methods
+ (RenameQueueProgressBar *)createWithItem:(CMISObject*) item withNewName:(NSString*)newName delegate:(id <RenameQueueDelegate>)del andMessage:(NSString *)message {
    RenameQueueProgressBar *bar = [[RenameQueueProgressBar alloc] initWithItem:item withNewName:newName delegate:del andMessage:message];
    return bar;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // we only cancel the connection when buttonIndex=0 (cancel)
    if (buttonIndex == 0)
    {
        [self cancel];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(renameQueueWasCancelled:)])
        {
            [self.delegate renameQueueWasCancelled:self];
        }
    }
}
@end
