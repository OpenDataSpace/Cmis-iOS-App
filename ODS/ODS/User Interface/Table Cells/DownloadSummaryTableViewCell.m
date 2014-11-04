//
//  DownloadSummaryTableViewCell.m
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadSummaryTableViewCell.h"
#import "DownloadManager.h"
#import "FileUtils.h"

NSString * const kDownloadSummaryCellIdentifier = @"DownloadSummaryCellIdentifier";

@implementation DownloadSummaryTableViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DownloadManager sharedManager] setQueueProgressDelegate:nil];
}

- (void)awakeFromNib {
    // Initialization code
    NSString *label =[NSString stringWithFormat:NSLocalizedString(@"download.summary.details", @"%@ remaining"),
     [FileUtils stringForLongFileSize:0]];
    [self.labelProgress setText:label];
    
    [self updateUploadCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadChanged:) name:kNotificationDownloadStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadChanged:) name:kNotificationDownloadFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadChanged:) name:kNotificationDownloadFailed object:nil];
    
    [[DownloadManager sharedManager] setQueueProgressDelegate:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)shouldIndentWhileEditing
{
    return NO;
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress
{
    DownloadManager *manager = [DownloadManager sharedManager];
    NSInteger operationCount = [[manager activeDownloads] count];
    [self.downloadsBadge setValue:operationCount];
    
    [self.progressBar setProgress:newProgress];
    [self.progressBar setHidden:NO];
    
    float bytesLeft = manager.downloadQueue.totalBytesToDownload - manager.downloadQueue.bytesDownloadedSoFar;//MAX(0, (1 - newProgress) * manager.downloadQueue.totalBytesToDownload);
    
    NSString *label = [NSString stringWithFormat:NSLocalizedString(@"download.summary.details", @"%@ remaining"),
                       [FileUtils stringForLongFileSize:bytesLeft]];
    [self.labelProgress setText:label];
}

#pragma mark - Download notifications

- (void)downloadChanged:(NSNotification *)notification
{
    [self updateUploadCount];
}

- (void) updateUploadCount {
    NSArray *activeDownloads = [[DownloadManager sharedManager] activeDownloads];
    [self.downloadsBadge setValue:[activeDownloads count]];
}

@end
