//
//  AbstractDownloadManager.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODSDownloadQueue.h"

#define kUseHash NO

@class DownloadInfo;

@interface AbstractDownloadManager : NSObject {
    NSMutableDictionary *_allDownloads;
}


@property (nonatomic, strong, readonly) ODSDownloadQueue *downloadQueue;

// Returns all the current downloads managed by this object
- (NSArray *)allDownloads;

// Returns all the active downloads managed by this object
- (NSArray *)activeDownloads;

// Returns all the failed downloads managed by this object
- (NSArray *)failedDownloads;
- (BOOL)isFailedDownload:(NSString *)cmisObjectId;

// Is the CMIS Object in the managed downloads queue?
- (BOOL)isManagedDownload:(NSString *)cmisObjectId;
- (BOOL)isDownloading:(NSString *)cmisObjectId;

// Return a managed download
- (DownloadInfo *)managedDownload:(NSString *)cmisObjectId;

// Queue a single download
- (void)queueDownloadInfo:(DownloadInfo *)downloadInfo;

- (void)queueRepositoryItem:(CMISObject *)repositoryItem withAccountUUID:(NSString *)accountUUID  withRepositoryID:(NSString*)repositoryID andTenantId:(NSString *)tenantId;
- (void)queueRepositoryItems:(NSArray *)repositoryItems withAccountUUID:(NSString *)accountUUID withRepositoryID:(NSString*)repositoryID andTenantId:(NSString *)tenantId;

// Queue multiple downloads
- (void)queueDownloadInfoArray:(NSArray *)downloadInfos;

// Remove a download
- (void)clearDownload:(NSString *)cmisObjectId;

// Remove multiple downloads
- (void)clearDownloads:(NSArray *)cmisObjectIds;

// Stop all active downloads
- (void)cancelActiveDownloads;

- (void)cancelActiveDownloadsForAccountUUID:(NSString *)accountUUID;

// Retry a download
- (BOOL)retryDownload:(NSString *)cmisObjectId;

- (void)successDownload:(DownloadInfo *)downloadInfo;
- (void)failedDownload:(DownloadInfo *)downloadInfo withError:(NSError *)error;

- (void)requestStarted:(CMISDownloadFileRequest *)request;
- (void)requestFinished:(CMISDownloadFileRequest *)request;
- (void)requestFailed:(CMISDownloadFileRequest *)request;
- (void)queueFinished:(ODSDownloadQueue *)queue;

- (void)setQueueProgressDelegate:(id)progressDelegate;
@end
