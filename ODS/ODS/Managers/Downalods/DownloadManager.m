//
//  DownloadManager.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadInfo.h"
#import "DownloadMetadata.h"
#import "CMISDownloadFileRequest.h"
#import "NSNotificationCenter+CustomNotification.h"
#import "LocalFileManager.h"

@implementation DownloadManager

#pragma mark - Shared Instance

+ (DownloadManager *)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (void)queueDownloadInfo:(DownloadInfo *)downloadInfo
{
    if (![self isManagedDownload:downloadInfo.cmisObjectId])
    {
        [super queueDownloadInfo:downloadInfo];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:downloadInfo, @"downloadInfo", downloadInfo.cmisObjectId, @"downloadObjectId", nil];
        ODSLogTrace(@"Download Info: %@", userInfo);
        
        [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:userInfo];
    }
}

- (void)clearDownload:(NSString *)cmisObjectId
{
    DownloadInfo *downloadInfo = [_allDownloads objectForKey:cmisObjectId];
    
    [super clearDownload:cmisObjectId];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:downloadInfo, @"downloadInfo", downloadInfo.cmisObjectId, @"downloadObjectId", nil];
    [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:userInfo];
}

- (void)clearDownloads:(NSArray *)cmisObjectIds
{
    if ([[cmisObjectIds lastObject] isKindOfClass:[NSString class]])
    {
        [super clearDownloads:cmisObjectIds];
        
        [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:nil];
    }
}
- (void)cancelActiveDownloads
{
    [super cancelActiveDownloads];
    
    [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:nil];
}

- (void)cancelActiveDownloadsForAccountUUID:(NSString *)accountUUID
{
    [super cancelActiveDownloadsForAccountUUID:accountUUID];
    [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:nil];
}

#pragma mark - ASINetworkQueueDelegateMethod

- (void)requestStarted:(CMISDownloadFileRequest *)request
{
    [super requestStarted:request];
    DownloadInfo *downloadInfo = request.downloadInfo;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:downloadInfo, @"downloadInfo", downloadInfo.cmisObjectId, @"downloadObjectId", nil];
    [[NSNotificationCenter defaultCenter] postDownloadStartedNotificationWithUserInfo:userInfo];
}

- (void)requestFinished:(CMISDownloadFileRequest *)request
{
    DownloadInfo *downloadInfo = request.downloadInfo;
    
    [super requestFinished:request];
    
    // we'll move the file from temp path to document folder.
    LocalFileManager *manager = [LocalFileManager sharedInstance];
    NSString *fileObjectId = [LocalFileManager objectIDFromFileObject:downloadInfo.repositoryItem withRepositoryId:downloadInfo.repositoryIdentifier];

    
    [manager setDownload:downloadInfo.downloadMetadata.downloadInfo forKey:fileObjectId withFilePath:downloadInfo.tempFilePath];
    
    ODSLogTrace(@"Successful download for file %@ with cmisObjectId %@", downloadInfo.repositoryItem.name, downloadInfo.cmisObjectId);
    
    [self successDownload:downloadInfo];
}

- (void)requestFailed:(CMISDownloadFileRequest *)request
{
    [super requestFailed:request];
}

- (void)queueFinished:(ODSDownloadQueue *)queue
{
    [super queueFinished:queue];
    
    [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:nil];
    
}

#pragma mark - Private Methods

- (void)successDownload:(DownloadInfo *)downloadInfo
{
    if ([_allDownloads objectForKey:downloadInfo.cmisObjectId])
    {
        [super successDownload:downloadInfo];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:downloadInfo, @"downloadInfo", downloadInfo.cmisObjectId, @"downloadObjectId", nil];
        [[NSNotificationCenter defaultCenter] postDownloadFinishedNotificationWithUserInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:userInfo];
        SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
                                                            inView:activeView()
                                                           message:[NSString stringWithFormat:@"%@ %@", downloadInfo.downloadMetadata.filename, NSLocalizedString(@"download.progress.successed", @"Download finished.")]
                                                             title:@""];
        notice.displayTime = 3.0;
        [notice show];
    }
    else
    {
        ODSLogTrace(@"The success download %@ is no longer managed by the DownloadManager, ignoring", downloadInfo.downloadMetadata.filename);
    }
}

- (void)failedDownload:(DownloadInfo *)downloadInfo withError:(NSError *)error
{
    if ([_allDownloads objectForKey:downloadInfo.cmisObjectId])
    {
        [super failedDownload:downloadInfo withError:error];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:downloadInfo, @"downloadInfo", downloadInfo.cmisObjectId, @"downloadObjectId", error, @"downloadError", nil];
        [[NSNotificationCenter defaultCenter] postDownloadFailedNotificationWithUserInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postDownloadQueueChangedNotificationWithUserInfo:userInfo];
    }
    else
    {
        ODSLogTrace(@"The failed download %@ is no longer managed by the DownloadManager, ignoring", downloadInfo.downloadMetadata.filename);
    }
}
@end
