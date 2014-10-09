//
//  UploadsManager.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadsManager.h"

NSString * const kUploadConfigurationFile = @"UploadsMetadata.plist";

@implementation UploadsManager

- (id)init
{
    return [super initWithConfigFile:kUploadConfigurationFile andUploadQueue:@"FDAddUploadQueue"];
}

- (void)queueUpload:(UploadInfo *)uploadInfo
{
    dispatch_async(self.addUploadQueue, ^{
        [super queueUpload:uploadInfo];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:uploadInfo, @"uploadInfo", uploadInfo.uuid, @"uploadUUID", nil];
        [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:userInfo];
    });
}

- (void)queueUploadArray:(NSArray *)uploads
{
    dispatch_async(self.addUploadQueue, ^{
        [super queueUploadArray:uploads];
        [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:nil];
    });
}

- (void)clearUpload:(NSString *)uploadUUID
{
    UploadInfo *uploadInfo = [self.allUploadsDictionary objectForKey:uploadUUID];
    
    [super clearUpload:uploadUUID];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:uploadInfo, @"uploadInfo", uploadInfo.uuid, @"uploadUUID", nil];
    [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:userInfo];
}

- (void)clearUploads:(NSArray *)uploads
{
    [super clearUploads:uploads];
    
    [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:nil];
}

- (void)cancelActiveUploads
{
    [super cancelActiveUploads];
    
    [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:nil];
}

- (void)cancelActiveUploadsForAccountUUID:(NSString *)accountUUID
{
    [super cancelActiveUploadsForAccountUUID:accountUUID];
    
    [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:nil];
}

- (BOOL)retryUpload:(NSString *)uploadUUID
{
    UploadInfo *uploadInfo = [self.allUploadsDictionary objectForKey:uploadUUID];
    
    [super retryUpload:uploadUUID];
    
    [[NSNotificationCenter defaultCenter] postUploadWaitingNotificationWithUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:uploadUUID, @"uploadUUID", uploadInfo, @"uploadInfo", nil]];
    
    NSString *uploadPath = [uploadInfo.uploadFileURL path];
    if(!uploadInfo || ![[NSFileManager defaultManager] fileExistsAtPath:uploadPath])
    {
        displayErrorMessageWithTitle(NSLocalizedString(@"uploads.retry.cannotRetry", @"The upload has permanently failed. Please start the upload again."), NSLocalizedString(@"uploads.cancelAll.title", @"Uploads"));
    }
    
    return YES;
}

#pragma mark - Upload File Request Delegate Method
- (void)requestStarted:(CMISUploadRequest *)request
{
    [super requestStarted:request];
    
    UploadInfo *uploadInfo = [(CMISUploadRequest *)request uploadInfo];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:uploadInfo, @"uploadInfo", uploadInfo.uuid, @"uploadUUID", nil];
    [[NSNotificationCenter defaultCenter] postUploadStartedNotificationWithUserInfo:userInfo];
}

- (void)requestFinished:(CMISUploadRequest *)request
{
    [super requestFinished:request];
}

- (void)requestFailed:(CMISUploadRequest *)request
{
    [super requestFailed:request];
}

- (void)requestQueueFinished:(ODSUploadQueue *)queue
{
    [super requestQueueFinished:queue];
    [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:nil];
}

#pragma mark - private methods

- (void)successUpload:(UploadInfo *)uploadInfo
{
    if([self.allUploadsDictionary objectForKey:uploadInfo.uuid])
    {
        [super successUpload:uploadInfo];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:uploadInfo, @"uploadInfo", uploadInfo.uuid, @"uploadUUID", nil];
        [[NSNotificationCenter defaultCenter] postUploadFinishedNotificationWithUserInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:userInfo];
        
    }
    else
    {
        ODSLogTrace(@"The success upload %@ is no longer managed by the UploadsManager, ignoring", [uploadInfo completeFileName]);
    }
    
}
- (void)failedUpload:(UploadInfo *)uploadInfo withError:(NSError *)error
{
    if([self.allUploadsDictionary objectForKey:uploadInfo.uuid])
    {
        [super failedUpload:uploadInfo withError:error];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:uploadInfo, @"uploadInfo", uploadInfo.uuid, @"uploadUUID", error, @"uploadError", nil];
        [[NSNotificationCenter defaultCenter] postUploadFailedNotificationWithUserInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postUploadQueueChangedNotificationWithUserInfo:userInfo];
    }
    else
    {
        ODSLogTrace(@"The failed upload %@ is no longer managed by the UploadsManager, ignoring", [uploadInfo completeFileName]);
    }
}

#pragma mark - Singleton

+ (UploadsManager *)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}
@end
