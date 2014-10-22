//
//  FailedDownloadsViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "FailedDownloadsViewController.h"
#import "DownloadInfo.h"
#import "DownloadManager.h"
#import "DownloadFailureTableViewCell.h"
#import "FailedTransferDetailViewController.h"

@interface FailedDownloadsViewController () {
    UIView *tableFooterView_;
}

@end

@implementation FailedDownloadsViewController
@synthesize failedDownloads = _failedDownloads;
@synthesize popover = _popover;
@synthesize downloadToDismiss = _downloadToDismiss;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.popover setDelegate:nil];
    
    _failedDownloads = nil;
    _popover = nil;
    _downloadToDismiss = nil;
    
}

- (id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadQueueChanged:) name:kNotificationDownloadQueueChanged object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // View will hold the clear button
    tableFooterView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 48.0f)];
    
    // The Clear All custom button
    UIButton *clearAll = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearAll setFrame:CGRectMake(64.0f, 8.0f, tableFooterView_.frame.size.width - 128.0f, tableFooterView_.frame.size.height - 16.0f)];
    [clearAll setTitle:NSLocalizedString(@"download.failures.clearAll", @"Clear All") forState:UIControlStateNormal];
    [clearAll.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    UIImage *buttonTemplate = [UIImage imageNamed:@"red-button"];
    UIImage *stretchedButtonImage = [buttonTemplate resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 5.0f, 7.0f, 5.0f)];
    [clearAll setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    [clearAll addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Bind the views
    [tableFooterView_ addSubview:clearAll];
    [self.tableView setTableFooterView:tableFooterView_];
    
    // Retry All toolbar button
    UIBarButtonItem *retryButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"download.failures.retryAll", @"Retry All") style:UIBarButtonItemStyleBordered target:self action:@selector(retryButtonAction:)];
    [self.navigationItem setRightBarButtonItem:retryButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setFailedDownloads:[NSMutableArray arrayWithArray:[[DownloadManager sharedManager] failedDownloads]]];
    [self.tableView reloadData];
}

- (void)setFailedDownloads:(NSMutableArray *)failedDownloads
{
    _failedDownloads = failedDownloads;
    
    if ([_failedDownloads count] == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.failedDownloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadFailureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadFailureCellIdentifier];
    if (!cell)
    {
        cell = [[DownloadFailureTableViewCell alloc] initWithIdentifier:kDownloadFailureCellIdentifier];
    }
    [cell setDownloadInfo:[self.failedDownloads objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kDefaultTableCellHeight;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DownloadInfo *downloadInfo = [self.failedDownloads objectAtIndex:indexPath.row];
    [self setDownloadToDismiss:downloadInfo];
    if (IS_IPAD)
    {
        FailedTransferDetailViewController *viewController = [[FailedTransferDetailViewController alloc] initWithTitle:NSLocalizedString(@"download.failureDetail.title", @"Download failed popover title")
                                                                                                               message:[downloadInfo.error localizedDescription]];
        [viewController setUserInfo:downloadInfo];
        [viewController setCloseTarget:self];
        [viewController setCloseAction:@selector(closeFailedDownload:)];
        
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
        [self setPopover:popoverController];
        [popoverController setPopoverContentSize:viewController.view.frame.size];
        [popoverController setDelegate:self];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.popover presentPopoverFromRect:cell.accessoryView.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"download.failureDetail.title", @"Failed Download")
                                     message:[downloadInfo.error localizedDescription]
                                    delegate:self
                           cancelButtonTitle:NSLocalizedString(@"Close", @"Close")
                           otherButtonTitles:NSLocalizedString(@"Retry", @"Retry"), nil] show];
    }
}

#pragma mark - FailedDownloadDetailViewController Delegate

// Called from the FailedDownloadDetailViewController and it means the user retry the failed upload
- (void)closeFailedDownload:(FailedTransferDetailViewController *)sender
{
    if (nil != self.popover && [self.popover isPopoverVisible])
    {
        [self.popover setDelegate:nil];
        [self.popover dismissPopoverAnimated:YES];
        [self setPopover:nil];
        
        DownloadInfo *downloadInfo = (DownloadInfo *)sender.userInfo;
        [[DownloadManager sharedManager] retryDownload:downloadInfo.cmisObjectId];
    }
}

#pragma mark - UIPopoverController Delegate methods

// Called when the popover was dismissed by the user by tapping in another part of the screen,
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[DownloadManager sharedManager] clearDownload:self.downloadToDismiss.cmisObjectId];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (IS_IPAD)
    {
        if (nil != self.popover && [self.popover isPopoverVisible])
        {
            [self.popover dismissPopoverAnimated:YES];
            [self setPopover:nil];
        }
    }
    
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        [[DownloadManager sharedManager] clearDownload:self.downloadToDismiss.cmisObjectId];
    }
    else
    {
        [[DownloadManager sharedManager] retryDownload:self.downloadToDismiss.cmisObjectId];
    }
}

#pragma mark - Download notifications

- (void)downloadQueueChanged:(NSNotification *)notification
{
    [self setFailedDownloads:[NSMutableArray arrayWithArray:[[DownloadManager sharedManager] failedDownloads]]];
    [self.tableView reloadData];
}

#pragma mark - Button actions

- (void)retryButtonAction:(id)sender
{
    for (DownloadInfo *downloadInfo in self.failedDownloads)
    {
        [[DownloadManager sharedManager] retryDownload:downloadInfo.cmisObjectId];
    }
}

- (void)clearButtonAction:(id)sender
{
    NSMutableArray *downloadObjectIds = [NSMutableArray arrayWithCapacity:[self.failedDownloads count]];
    for (DownloadInfo *downloadInfo in self.failedDownloads)
    {
        [downloadObjectIds addObject:downloadInfo.cmisObjectId];
    }
    
    [[DownloadManager sharedManager] clearDownloads:downloadObjectIds];
}

@end
