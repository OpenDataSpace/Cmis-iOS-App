//
//  UploadsViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadsViewController.h"
#import "UploadsManager.h"
#import "UploadProgressTableViewCell.h"
#import "FailedTransferDetailViewController.h"

NSInteger const kCancelUploadPrompt = 2;
NSInteger const kDismissFailedUploadPrompt = 3;

@interface UploadsViewController ()

@end

@implementation UploadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:NSLocalizedString(@"manage.uploads.view.title", @"Uploads")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadQueueChanged:) name:kNotificationUploadQueueChanged object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createUploadCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Delegate & Datasource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableSections) {
        NSArray *uploads = [self.tableSections objectAtIndex:section];
        return [uploads count];
    }
    return 0;
    //return [[[UploadsManager sharedManager] allUploads] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableSections) {
        NSArray *uploads = [self.tableSections objectAtIndex:indexPath.section];
        return [uploads objectAtIndex:indexPath.row];
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.tableSections) {
        NSArray *uploads = [self.tableSections objectAtIndex:indexPath.section];
        if ([uploads count] > indexPath.row) {
            UploadProgressTableViewCell *cell = [uploads objectAtIndex:indexPath.row];
            UploadInfo *uploadInfo = cell.uploadInfo;
            
            if (cell.uploadInfo && cell.uploadInfo.uploadStatus == UploadInfoStatusFailed) {  //retry
                [self setUploadToDismiss:uploadInfo];
                if (IS_IPAD)
                {
                    FailedTransferDetailViewController *viewController = [[FailedTransferDetailViewController alloc] initWithTitle:NSLocalizedString(@"Upload Failed", @"Upload failed popover title")
                                                                                                                           message:[uploadInfo.error localizedDescription]];
                    
                    [viewController setUserInfo:uploadInfo];
                    [viewController setCloseTarget:self];
                    [viewController setCloseAction:@selector(closeFailedUpload:)];
                    
                    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
                    [self setPopover:popoverController];
                    [popoverController setPopoverContentSize:viewController.view.frame.size];
                    [popoverController setDelegate:self];
                    
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    
                    if(cell.accessoryView.window != nil)
                    {
                        [self.popover presentPopoverFromRect:cell.accessoryView.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                    }
                }
                else
                {
                    UIAlertView *uploadFailDetail = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Upload Failed", @"")
                                                                                message:[uploadInfo.error localizedDescription]
                                                                               delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Close", @"Close")
                                                                      otherButtonTitles:NSLocalizedString(@"Retry", @"Retry"), nil];
                    [uploadFailDetail setTag:kDismissFailedUploadPrompt];
                    [uploadFailDetail show];
                }
            }else if (cell.uploadInfo && cell.uploadInfo.uploadStatus != UploadInfoStatusFailed) {  //cancel?
                [self setUploadToCancel:cell];
                UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"uploads.cancelAll.title", @"Uploads")
                                                                        message:NSLocalizedString(@"uploads.cancel.body", @"Would you like to...")
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                                              otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
                [confirmAlert setTag:kCancelUploadPrompt];
                [confirmAlert show];
            }
        }
    }
}

- (void) createUploadCells {
    self.tableSections = [NSMutableArray array];
    
    NSArray *uploads = [[UploadsManager sharedManager] allUploads];
    NSMutableArray *uploadSection = [NSMutableArray array];
    
    UploadProgressTableViewCell *cell = nil;
    for (UploadInfo *upload in uploads) {
        cell = (UploadProgressTableViewCell*)[self createTableViewCellFromNib:@"UploadProgressTableViewCell"];
        
        [cell setUploadInfo:upload];
        [uploadSection addObject:cell];
    }
    
    [self.tableSections addObject:uploadSection];
}

- (BOOL) enableRefreshController {
    return NO;
}

- (void) updateQueue {
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *uploads = [self.tableSections objectAtIndex:0];
    for (NSUInteger index = 0; index < [uploads count]; index++) {
        UploadProgressTableViewCell *cellWrapper = [uploads objectAtIndex:index];
        // We remove the finished cells
        if (cellWrapper.uploadInfo &&
            [cellWrapper.uploadInfo uploadStatus] == UploadInfoStatusUploaded)// &&
            //![[UploadsManager sharedManager] isManagedUpload:cellWrapper.uploadInfo.uuid])
        {
            ODSLogTrace(@"We are displaying an upload that is not currently managed");
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [indexPaths addObject:indexPath];
            [indexSet addIndex:index];
        }
    }
    
    if ([indexPaths count] > 0)
    {
        [uploads removeObjectsAtIndexes:indexSet];
        [self.tableView reloadData];
    }
}

#pragma mark - NSNotificationCenter methods
- (void)uploadQueueChanged:(NSNotification *) notification {
    [self performSelectorOnMainThread:@selector(updateQueue) withObject:self waitUntilDone:NO];
}

#pragma mark UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (IS_IPAD)
    {
        if ([self.popover isPopoverVisible])
        {
            [self.popover dismissPopoverAnimated:YES];
            [self setPopover:nil];
        }
    }
    
    if (alertView.tag == kCancelUploadPrompt)
    {
        UploadProgressTableViewCell *uploadToCancel = [self uploadToCancel];
        UploadInfo *uploadInfo = [uploadToCancel uploadInfo];
        
        if(buttonIndex != alertView.cancelButtonIndex && ([uploadInfo uploadStatus] == UploadInfoStatusActive || [uploadInfo uploadStatus] == UploadInfoStatusUploading))
        {
            NSMutableArray *uploadCells = [self.tableSections objectAtIndex:0];
            if (uploadCells) {
                NSUInteger indexToCancel = [uploadCells indexOfObject:uploadToCancel];
                if (indexToCancel != NSNotFound) {
                    [uploadCells removeObjectAtIndex:indexToCancel];
                    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToCancel inSection:0];
                    //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [[UploadsManager sharedManager] clearUpload:uploadInfo.uuid];
                    [self.tableView reloadData];
                }
            }
        }
        
        return;
    }
    else if (alertView.tag == kDismissFailedUploadPrompt)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            [[UploadsManager sharedManager] clearUpload:self.uploadToDismiss.uuid];
        }
        else
        {
            [[UploadsManager sharedManager] retryUpload:self.uploadToDismiss.uuid];
        }
    }
    
}

#pragma mark - UIPopoverController Delegate methods

// This is called when the popover was dismissed by the user by tapping in another part of the screen,
// We want to to clear the upload
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[UploadsManager sharedManager] clearUpload:self.uploadToDismiss.uuid];
    [self.tableView reloadData];
}

#pragma mark - FailedUploadDetailViewController Delegate

// This is called from the FailedTransferDetailViewController and it means the user wants to retry the failed upload
- (void)closeFailedUpload:(FailedTransferDetailViewController *)sender
{
    if (nil != self.popover && [self.popover isPopoverVisible])
    {
        // Removing us as the delegate so we don't get the dismiss call at this point the user retried the upload and
        // we don't want to clear the upload
        [self.popover setDelegate:nil];
        [self.popover dismissPopoverAnimated:YES];
        [self setPopover:nil];
        
        UploadInfo *uploadInfo = (UploadInfo *)sender.userInfo;
        [[UploadsManager sharedManager] retryUpload:uploadInfo.uuid];
    }
}
@end
