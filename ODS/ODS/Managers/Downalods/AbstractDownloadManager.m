//
//  AbstractDownloadManager.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AbstractDownloadManager.h"
#import "CMISDownloadFileRequest.h"
#import "DownloadInfo.h"

@interface AbstractDownloadManager() {
    NSMutableDictionary *_allDownloads;
}
@property (nonatomic, strong, readwrite) ODSDownloadQueue *downloadQueue;
@end

@implementation AbstractDownloadManager
@synthesize downloadQueue = _downloadQueue;

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self)
    {
        [self setDownloadQueue:[ODSDownloadQueue queue]];
        [self.downloadQueue setMaxConcurrentOperationCount:2];
        [self.downloadQueue setDelegate:self];
        [self.downloadQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [self.downloadQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        [self.downloadQueue setRequestDidStartSelector:@selector(requestStarted:)];
        [self.downloadQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        
        _allDownloads = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Public Methods

- (NSArray *)allDownloads
{
    return [_allDownloads allValues];
}

- (NSArray *)filterDownloadsWithPredicate:(NSPredicate *)predicate
{
    NSArray *allDownloads = [self allDownloads];
    return [allDownloads filteredArrayUsingPredicate:predicate];
}

- (BOOL)isDownloadState:(DownloadInfoStatus)downloadState forManagedDownload:(NSString *)cmisObjectId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadStatus == %@ AND cmisObjectId MATCHES %@", [NSNumber numberWithInt:downloadState], cmisObjectId];
    NSArray *matchingDownloads = [self filterDownloadsWithPredicate:predicate];
    
    return matchingDownloads.count > 0;
}

- (NSArray *)activeDownloads
{
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"downloadStatus == %@ OR downloadStatus == %@", [NSNumber numberWithInt:DownloadInfoStatusActive], [NSNumber numberWithInt:DownloadInfoStatusDownloading]];
    return [self filterDownloadsWithPredicate:activePredicate];
}

- (NSArray *)failedDownloads
{
    NSPredicate *failedPredicate = [NSPredicate predicateWithFormat:@"downloadStatus == %@", [NSNumber numberWithInt:DownloadInfoStatusFailed]];
    return [self filterDownloadsWithPredicate:failedPredicate];
}

- (BOOL)isFailedDownload:(NSString *)cmisObjectId
{
    return [self isDownloadState:DownloadInfoStatusFailed forManagedDownload:cmisObjectId];
}

- (BOOL)isManagedDownload:(NSString *)cmisObjectId
{
    return [_allDownloads objectForKey:cmisObjectId] != nil;
}

- (BOOL)isDownloading:(NSString *)cmisObjectId
{
    return [self isDownloadState:DownloadInfoStatusDownloading forManagedDownload:cmisObjectId];
}

- (DownloadInfo *)managedDownload:(NSString *)cmisObjectId
{
    return [_allDownloads objectForKey:cmisObjectId];
}

- (void)addDownloadToManaged:(DownloadInfo *)downloadInfo
{
    [_allDownloads setObject:downloadInfo forKey:downloadInfo.cmisObjectId];
    
    CMISDownloadFileRequest *request = [CMISDownloadFileRequest cmisDownloadRequestWithDownloadInfo:downloadInfo];

    [request setTotalBytes:0];
    [request setDownloadInfo:downloadInfo];
    [downloadInfo setDownloadStatus:DownloadInfoStatusActive];
    [downloadInfo setDownloadRequest:request];
    [self.downloadQueue addOperation:request];
}

- (void)queueDownloadInfo:(DownloadInfo *)downloadInfo
{
    if (![self isManagedDownload:downloadInfo.cmisObjectId])
    {
        [self addDownloadToManaged:downloadInfo];
        [self.downloadQueue go];
        
    }
}

- (void)queueDownloadInfoArray:(NSArray *)downloadInfos
{
    for (DownloadInfo *downloadInfo in downloadInfos)
    {
        [self addDownloadToManaged:downloadInfo];
    }
}

- (void)clearDownload:(NSString *)cmisObjectId
{
    DownloadInfo *downloadInfo = [_allDownloads objectForKey:cmisObjectId];
    [_allDownloads removeObjectForKey:cmisObjectId];
    
    if (downloadInfo.downloadRequest)
    {
        [downloadInfo.downloadRequest clearDelegatesAndCancel];
        CGFloat remainingBytes = [downloadInfo.downloadRequest totalBytes] - [downloadInfo.downloadRequest downloadedBytes];
        [self.downloadQueue setTotalBytesToDownload:self.downloadQueue.totalBytesToDownload - remainingBytes];
        
        // If the last request was cancelled, we may not get the queueFinished delegate selector called
        if ([_allDownloads count] == 0)
        {
            [self.downloadQueue cancelAllOperations];
        }
    }
}

- (void)clearDownloads:(NSArray *)cmisObjectIds
{
    [_allDownloads removeObjectsForKeys:cmisObjectIds];
}

- (void)cancelActiveDownloads
{
    NSArray *activeDownloads = [self activeDownloads];
    for (DownloadInfo *activeDownload in activeDownloads)
    {
        [_allDownloads removeObjectForKey:activeDownload.cmisObjectId];
    }
    
    [self.downloadQueue cancelAllOperations];
}

- (void)cancelActiveDownloadsForAccountUUID:(NSString *)accountUUID
{
    [self.downloadQueue setSuspended:YES];
    NSArray *activeDownloads = [self activeDownloads];
    for (DownloadInfo *activeDownload in activeDownloads)
    {
        if ([activeDownload.selectedAccountUUID isEqualToString:accountUUID])
        {
            [activeDownload.downloadRequest cancel];
            [_allDownloads removeObjectForKey:activeDownload.cmisObjectId];
        }
    }
    
    [self.downloadQueue setSuspended:NO];
}


- (BOOL)retryDownload:(NSString *)cmisObjectId
{
    DownloadInfo *downloadInfo = [_allDownloads objectForKey:cmisObjectId];
    if (downloadInfo)
    {
        [self clearDownload:downloadInfo.cmisObjectId];
        [self queueDownloadInfo:downloadInfo];
        return YES;
    }
    return NO;
}

- (void)setQueueProgressDelegate:(id) progressDelegate
{
    [self.downloadQueue setDownloadProgressDelegate:progressDelegate];
}

#pragma mark - DownloadQueueDelegateMethod

- (void)requestStarted:(CMISDownloadFileRequest *)request
{
    DownloadInfo *downloadInfo = request.downloadInfo;
    [downloadInfo setDownloadStatus:DownloadInfoStatusDownloading];
}

- (void)requestFinished:(CMISDownloadFileRequest *)request
{
    DownloadInfo *downloadInfo = request.downloadInfo;
    [downloadInfo setDownloadRequest:nil];
    
    //handle downloaded file
    
}

- (void)requestFailed:(CMISDownloadFileRequest *)request
{
    DownloadInfo *downloadInfo = request.downloadInfo;
    [downloadInfo setDownloadRequest:nil];
    [self failedDownload:downloadInfo withError:request.error];
}

- (void)queueFinished:(ODSDownloadQueue *)queue
{
    [self.downloadQueue cancelAllOperations];
}

#pragma mark - Private Methods

- (void)successDownload:(DownloadInfo *)downloadInfo {
    [downloadInfo setDownloadStatus:DownloadInfoStatusDownloaded];
    
    // We don't manage successful downloads
    [_allDownloads removeObjectForKey:downloadInfo.cmisObjectId];
    
}

- (void)failedDownload:(DownloadInfo *)downloadInfo withError:(NSError *)error
{
    ODSLogTrace(@"Download Failed for file cmisObjectId %@ with error: %@", downloadInfo.cmisObjectId, error);
    [downloadInfo setDownloadStatus:DownloadInfoStatusFailed];
    [downloadInfo setError:error];
}

@end
