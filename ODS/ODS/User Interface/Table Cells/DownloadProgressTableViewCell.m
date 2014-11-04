//
//  DownloadProgressTableViewCell.m
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadProgressTableViewCell.h"
#import "DownloadMetadata.h"
#import "DownloadInfo.h"
#import "CMISDownloadFileRequest.h"
#import "UIColor+Theme.h"
#import "DownloadManager.h"
#import "FileUtils.h"

NSString * const kDownloadProgressCellIdentifier = @"DownloadProgressCellIdentifier";

@implementation DownloadProgressTableViewCell
@synthesize downloadInfo = _downloadInfo;
@synthesize alertView = _alertView;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_downloadInfo.downloadRequest setDownloadProgressDelegate:nil];
    [self.alertView setDelegate:nil];
    
    _downloadInfo = nil;
    _alertView = nil;

}

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadChanged:) name:kNotificationDownloadStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadChanged:) name:kNotificationDownloadFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadChanged:) name:kNotificationDownloadFailed object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setDownloadInfo:(DownloadInfo *)downloadInfo {
    if (downloadInfo) {
        _downloadInfo = downloadInfo;
        self.labelFileName.text = [[_downloadInfo downloadMetadata] filename];
        [self.imgFileIcon setImage:imageForFilename([[_downloadInfo downloadMetadata] filename])];
        
        CMISDownloadFileRequest *request = _downloadInfo.downloadRequest;
        [request setDownloadProgressDelegate:self];
        
        switch (downloadInfo.downloadStatus)
        {
            case DownloadInfoStatusDownloaded:
                [self downloadedState];
                break;
                
            case DownloadInfoStatusDownloading:
                [self downloadingState];
                break;
                
            case DownloadInfoStatusFailed:
                [self failedState];
                break;
                
            default:
                [self defaultState];
                break;
        }
        
        [self setNeedsLayout];
        [self setNeedsDisplay];

    }
}

#pragma mark - UI methods

- (void)defaultState
{
    [self.labelDownloadStatus setText:NSLocalizedString(@"download.progress.waiting", @"Waiting to download...")];
    [self.labelDownloadStatus setFont:[UIFont italicSystemFontOfSize:12.0f]];
    [self.labelDownloadStatus setTextColor:[UIColor colorWithHexRed:110 green:110 blue:110 alphaTransparency:1]];
    [self setAccessoryView:[self makeCloseDisclosureButton]];
    [self.progressBar setHidden:YES];
    [self.labelDownloadInfo setHidden:YES];
    [self.labelDownloadStatus setHidden:NO];
}

- (void)downloadedState
{
    // Not much to do - the cell will be removed automatically
    [[self alertView] dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
    [self setAccessoryView:nil];
}

- (void)downloadingState
{
    CMISDownloadFileRequest *request = _downloadInfo.downloadRequest;
    [request setDownloadProgressDelegate:self];
    
    float bytesDownloaded = request.downloadedBytes;
    bytesDownloaded = MAX(0, bytesDownloaded);
    float totalBytesToDownload = request.totalBytes;
    
    NSString *label = [NSString stringWithFormat:NSLocalizedString(@"download.progress.details", @"%@ of %@"),
                       [FileUtils stringForLongFileSize:bytesDownloaded],
                       [FileUtils stringForLongFileSize:totalBytesToDownload]];
    [self.labelDownloadInfo setText:label];
    [self.labelDownloadInfo setFont:[UIFont systemFontOfSize:12.0f]];
    [self.labelDownloadInfo setTextColor:[UIColor blackColor]];
    [self setAccessoryView:[self makeCloseDisclosureButton]];
    
    float progressAmount = (float)(((request.downloadedBytes) * 1.0) / ((request.totalBytes) * 1.0));
    [self setProgress:progressAmount];
    [self.progressBar setHidden:NO];
    [self.labelDownloadStatus setHidden:YES];
    [self.labelDownloadInfo setHidden:NO];
}

- (void)failedState
{
    [self.progressBar setHidden:YES];
    [self.labelDownloadStatus setText:NSLocalizedString(@"download.progress.failed", @"Failed to download")];
    [self.labelDownloadStatus setTextColor:[UIColor redColor]];
    [self setAccessoryView:nil];
    
    [self.labelDownloadStatus setHidden:NO];
    [self.labelDownloadInfo setHidden:YES];
    
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
}

- (UIButton *)makeCloseDisclosureButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"stop-transfer"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"download.cancel.title", @"Downloads")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"download.cancel.body", @"Would you like to..."), self.downloadInfo.downloadMetadata.filename]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                                  otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    [self setAlertView:confirmAlert];
    [confirmAlert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex && (self.downloadInfo.downloadStatus == DownloadInfoStatusActive || self.downloadInfo.downloadStatus == DownloadInfoStatusDownloading))
    {
        [[DownloadManager sharedManager] clearDownload:self.downloadInfo.cmisObjectId];
    }
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress
{
    [self.progressBar setProgress:newProgress];
    
    CMISDownloadFileRequest *request = self.downloadInfo.downloadRequest;
    float bytesDownloaded = request.downloadedBytes;
    bytesDownloaded = MAX(0, bytesDownloaded);
    float totalBytesToDownload = request.totalBytes;
    
    NSString *label = [NSString stringWithFormat:NSLocalizedString(@"download.progress.details", @"%@ of %@"),
                       [FileUtils stringForLongFileSize:bytesDownloaded],
                       [FileUtils stringForLongFileSize:totalBytesToDownload]];
    [self.labelDownloadInfo setText:label];
}

#pragma mark - Notification methods

- (void)downloadChanged:(NSNotification *)notification
{
    DownloadInfo *downloadInfo = [notification.userInfo objectForKey:@"downloadInfo"];
    if ([downloadInfo.cmisObjectId isEqualToString:self.downloadInfo.cmisObjectId])
    {
        [self setDownloadInfo:downloadInfo];
    }
}

@end
