//
//  ActiveDownloadsViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ActiveDownloadsViewController.h"
#import "DownloadProgressTableViewCell.h"

NSInteger sortActiveDownloads(DownloadInfo *d1, DownloadInfo *d2, void *context)
{
    if (d1.downloadStatus == DownloadInfoStatusDownloading)
    {
        if (d2.downloadStatus == DownloadInfoStatusDownloading)
        {
            return NSOrderedSame;
        }
        return NSOrderedAscending;
    }
    if (d2.downloadStatus == DownloadInfoStatusDownloading)
    {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

@interface ActiveDownloadsViewController ()
- (void)stopAllButtonAction:(id)sender;
@end

@implementation ActiveDownloadsViewController
@synthesize activeDownloads = _activeDownloads;
@synthesize clearButton = _clearButton;
@synthesize alertView = _alertView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.alertView setDelegate:nil];
    
    _activeDownloads = nil;
    _clearButton = nil;
    _alertView = nil;
}

- (id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadQueueChanged:) name:kNotificationDownloadQueueChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStarted:) name:kNotificationDownloadStarted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:kNotificationDownloadFinished object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // The Stop All custom button
    UIBarButtonItem *stopAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"download.progress.stopAll", @"Stop All") style:UIBarButtonItemStyleDone target:self action:@selector(stopAllButtonAction:)];
    styleButtonAsDestructiveAction(stopAll);
    [self.navigationItem setRightBarButtonItem:stopAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *activeDownloads = [[DownloadManager sharedManager] activeDownloads];
    [self setActiveDownloads:[NSMutableArray arrayWithArray:[activeDownloads sortedArrayUsingFunction:sortActiveDownloads context:NULL]]];
    [self.tableView reloadData];
}

- (void)setActiveDownloads:(NSMutableArray *)activeDownloads
{
    _activeDownloads = activeDownloads;
    
    if ([_activeDownloads count] == 0)
    {
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSIndexPath *)indexPathForObjectId:(NSString *)cmisObjectId
{
    NSIndexPath *indexPath = nil;
    
    for (DownloadInfo *downloadInfo in self.activeDownloads)
    {
        if ([downloadInfo.cmisObjectId isEqualToString:cmisObjectId])
        {
            indexPath = [NSIndexPath indexPathForRow:[self.activeDownloads indexOfObject:downloadInfo] inSection:0];
            break;
        }
    }
    
    return indexPath;
}

#pragma mark - UITableViewDataSource delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activeDownloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadProgressCellIdentifier];
    if (!cell)
    {
        cell = (DownloadProgressTableViewCell*)[self createTableViewCellFromNib:@"DownloadProgressTableViewCell"];
    }
    [cell setDownloadInfo:[self.activeDownloads objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - Download notifications

- (void)downloadQueueChanged:(NSNotification *)notification
{
    if ([[DownloadManager sharedManager] activeDownloads].count == 0)
    {
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (NSUInteger index = 0; index < [self.activeDownloads count]; index++)
        {
            DownloadInfo *downloadInfo = [self.activeDownloads objectAtIndex:index];
            DownloadInfoStatus status = downloadInfo.downloadStatus;
            // Throw away inactive, downloaded or removed downloads
            if (status == DownloadInfoStatusInactive || status == DownloadInfoStatusDownloaded || [[DownloadManager sharedManager] isManagedDownload:downloadInfo.cmisObjectId] == NO)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [indexPaths addObject:indexPath];
                [indexSet addIndex:index];
            }
        }
        
        if ([indexPaths count] > 0)
        {
            [self.activeDownloads removeObjectsAtIndexes:indexSet];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)downloadStarted:(NSNotification *)notification
{
    NSString *cmisObjectId = [notification.userInfo objectForKey:@"downloadObjectId"];
    NSIndexPath *indexPath = [self indexPathForObjectId:cmisObjectId];
    
    if (indexPath != nil && indexPath.row > 1)
    {
        NSInteger moveFromIndex = indexPath.row;
        NSInteger moveToIndex = 0;
        
        while ([(DownloadInfo *)[self.activeDownloads objectAtIndex:moveToIndex] downloadStatus] == DownloadInfoStatusDownloading)
        {
            moveToIndex++;
        }
        
        DownloadInfo *downloadInfo = [self.activeDownloads objectAtIndex:moveFromIndex];
        [self.activeDownloads removeObjectAtIndex:moveFromIndex];
        [self.activeDownloads insertObject:downloadInfo atIndex:moveToIndex];
        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:moveFromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:moveToIndex inSection:0]];
    }
}

- (void)downloadFinished:(NSNotification *)notification
{
    NSString *cmisObjectId = [notification.userInfo objectForKey:@"downloadObjectId"];
    NSIndexPath *indexPath = [self indexPathForObjectId:cmisObjectId];
    
    if (indexPath != nil)
    {
        DownloadProgressTableViewCell *cell = (DownloadProgressTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell setDownloadInfo:nil];
        [self.activeDownloads removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Button actions

- (void)stopAllButtonAction:(id)sender
{
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"download.cancel.title", @"Downloads")
                                                            message:NSLocalizedString(@"download.cancelAll.body", @"Would you like to...")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                                  otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    [self setAlertView:confirmAlert];
    [confirmAlert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [[DownloadManager sharedManager] cancelActiveDownloads];
    }
}

@end
