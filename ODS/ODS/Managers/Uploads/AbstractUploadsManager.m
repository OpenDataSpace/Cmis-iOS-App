//
//  AbstractUploadsManager.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AbstractUploadsManager.h"
#import "FileUtils.h"
#import "FileProtectionManager.h"
#import "AccountManager.h"

@interface AbstractUploadsManager ()
@property (nonatomic, strong, readwrite) ODSUploadQueue *uploadsQueue;
@end

@implementation AbstractUploadsManager
@synthesize uploadsQueue = _uploadsQueue;
@synthesize configFile = _configFile;
@synthesize addUploadQueue = _addUploadQueue;
@synthesize allUploadsDictionary = _allUploadsDictionary;

- (id)initWithConfigFile:(NSString *)file andUploadQueue:(NSString *) queue
{
    self = [super init];
    if(self)
    {
        self.configFile = file;
        [self setAddUploadQueue:dispatch_queue_create([queue cStringUsingEncoding:NSASCIIStringEncoding], NULL)];
        
        //We need to restore the uploads data source
        NSString *uploadsStorePath = [FileUtils pathToConfigFile:self.configFile];
        NSData *serializedUploadsData = [NSData dataWithContentsOfFile:uploadsStorePath];
        
        if (serializedUploadsData && serializedUploadsData.length > 0) {
            //Complete protection for uploads metadata only if it already has data in it
            [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:uploadsStorePath];
            NSMutableDictionary *deserializedDict = [NSKeyedUnarchiver unarchiveObjectWithData:serializedUploadsData];
            [self setAllUploadsDictionary:[NSMutableDictionary dictionary]];
        }
        
//        if (self.allUploadsDictionary == nil)
//        {
//            [self setAllUploadsDictionary:[NSMutableDictionary dictionary]];
//        }
        
        [self setUploadsQueue:[ODSUploadQueue queue]];
        [self.uploadsQueue setMaxConcurrentOperationCount:2];
        [self.uploadsQueue setDelegate:self];
        
        [self.uploadsQueue setShouldCancelAllRequestsOnFailure:NO];
        [self.uploadsQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [self.uploadsQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [self.uploadsQueue setRequestDidStartSelector:@selector(requestStarted:)];
        [self.uploadsQueue setQueueDidFinishSelector:@selector(requestQueueFinished:)];
        
        [self initQueue];
    }
    
    return self;
}

- (NSArray *)allUploads
{
    return [self.allUploadsDictionary allValues];
}

- (NSArray *)filterUploadsWithPredicate:(NSPredicate *)predicate
{
    NSArray *allUploads = [self allUploads];
    return [allUploads filteredArrayUsingPredicate:predicate];
}

- (NSArray *)activeUploads
{
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"uploadStatus == %@ OR uploadStatus == %@", [NSNumber numberWithInt:UploadInfoStatusActive], [NSNumber numberWithInt:UploadInfoStatusUploading]];
    return [self filterUploadsWithPredicate:activePredicate];
}

- (NSArray *)failedUploads
{
    NSPredicate *failedPredicate = [NSPredicate predicateWithFormat:@"uploadStatus == %@", [NSNumber numberWithInt:UploadInfoStatusFailed]];
    return [self filterUploadsWithPredicate:failedPredicate];
}

- (BOOL)isManagedUpload:(NSString *)uuid
{
    return [self.allUploadsDictionary objectForKey:uuid] != nil;
}


- (void)addUploadToManaged:(UploadInfo *)uploadInfo httpMethod:(NSString *) method
{
    [self.allUploadsDictionary setObject:uploadInfo forKey:uploadInfo.uuid];
    
    CMISUploadRequest *request = [CMISUploadRequest cmisUploadRequestWithUploadInfo:uploadInfo];
    
    //[request setCancelledPromptPasswordSelector:@selector(cancelledPasswordPrompt:)]; //TODO:password prompt handle
    //[request setPromptPasswordDelegate:self];
    //[request setSuppressAccountStatusUpdateOnError:YES];
    [uploadInfo setUploadStatus:UploadInfoStatusActive];
    [uploadInfo setUploadRequest:request];
    
    [self.uploadsQueue addOperation:request];
}

- (void)queueUpload:(UploadInfo *)uploadInfo
{
    [self addUploadToManaged:uploadInfo httpMethod:@"POST"];
    
    [self saveUploadsData];
    // We call go to the queue to start it, if the queue has already started it will not have any effect in the queue.
    [self.uploadsQueue go];
    ODSLogTrace(@"Starting the upload for file %@ with uuid %@", uploadInfo.completeFileName, uploadInfo.uuid);
}

- (void)queueUploadArray:(NSArray *)uploads
{
    [self.uploadsQueue setSuspended:YES];
    for(UploadInfo *uploadInfo in uploads)
    {
        [self addUploadToManaged:uploadInfo httpMethod:@"POST"];
    }
    
    [self saveUploadsData];
    // We call go to the queue to start it, if the queue has already started it will not have any effect in the queue.
    [self.uploadsQueue go];
    ODSLogTrace(@"Starting the upload of %d items", [uploads count]);
    
}

-(void) queueUpdateUpload:(UploadInfo *)uploadInfo
{
    [self addUploadToManaged:uploadInfo httpMethod:@"PUT"];
    
    [self saveUploadsData];
    // We call go to the queue to start it, if the queue has already started it will not have any effect in the queue.
    [self.uploadsQueue go];
    ODSLogTrace(@"Starting the upload for file %@ with uuid %@", [uploadInfo completeFileName], [uploadInfo uuid]);
    
}

- (void)clearUpload:(NSString *)uploadUUID
{
    UploadInfo *uploadInfo = [self.allUploadsDictionary objectForKey:uploadUUID];
    [self.allUploadsDictionary removeObjectForKey:uploadUUID];
    
    if(uploadInfo.uploadRequest)
    {
        [uploadInfo.uploadRequest clearDelegatesAndCancel];
        CGFloat remainingBytes = [uploadInfo.uploadRequest totalBytes] - [uploadInfo.uploadRequest sentBytes];
        [self.uploadsQueue setTotalBytesToUpload:[self.uploadsQueue totalBytesToUpload] - remainingBytes ];
    }
    
    
    [self saveUploadsData];
    
}

- (void)clearUploads:(NSArray *)uploads
{
    if([[uploads lastObject] isKindOfClass:[NSString class]])
    {
        [self.allUploadsDictionary removeObjectsForKeys:uploads];
        [self saveUploadsData];
    }
}

- (void)cancelActiveUploads
{
    NSArray *activeUploads = [self activeUploads];
    for(UploadInfo *activeUpload in activeUploads)
    {
        [self.allUploadsDictionary removeObjectForKey:activeUpload.uuid];
    }
    [self saveUploadsData];
    [self.uploadsQueue cancelAllOperations];
}

- (void)cancelActiveUploadsForAccountUUID:(NSString *)accountUUID
{
    [self.uploadsQueue setSuspended:YES];
    NSArray *activeUploads = [self activeUploads];
    for (UploadInfo *activeUpload in activeUploads)
    {
        if ([activeUpload.selectedAccountUUID isEqualToString:accountUUID])
        {
            [activeUpload.uploadRequest cancel];
            [self.allUploadsDictionary removeObjectForKey:activeUpload.uuid];
        }
    }
    
    [self.uploadsQueue setSuspended:NO];
}

- (BOOL)retryUpload:(NSString *)uploadUUID
{
    UploadInfo *uploadInfo = [self.allUploadsDictionary objectForKey:uploadUUID];
    
    //NSString *uploadPath = [uploadInfo.uploadFileURL path];
    if(!uploadInfo || ![uploadInfo sourceFileExists])
    {
        // We clear the upload since there's no reason to keep the upload visible
        if(uploadInfo)
        {
            [self clearUpload:uploadUUID];
        }
        
        displayErrorMessageWithTitle(NSLocalizedString(@"uploads.retry.cannotRetry", @"The upload has permanently failed. Please start the upload again."), NSLocalizedString(@"uploads.cancelAll.title", @"Uploads"));
        
        return NO;
    }
    
    [self queueUpload:uploadInfo];
    
    return YES;
}

#pragma mark - private methods
- (void)initQueue
{
    CMISUploadRequest *request = nil;
    BOOL pendingUploads = NO;
    
    for(UploadInfo *uploadInfo in [self.allUploadsDictionary allValues])
    {
        // Only Active uploads should be initialized, included the Inactive ones just to be sure
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[uploadInfo.uploadFileURL absoluteString]];
        BOOL accountExists = [[AccountManager sharedManager] accountInfoForUUID:uploadInfo.selectedAccountUUID] != nil;
        
        if((uploadInfo.uploadStatus == UploadInfoStatusActive || uploadInfo.uploadStatus == UploadInfoStatusInactive) && fileExists && accountExists)
        {
            [uploadInfo setUploadStatus:UploadInfoStatusActive];
            
            request = [CMISUploadRequest cmisUploadRequestWithUploadInfo:uploadInfo];
            [self.uploadsQueue addOperation:request];
            
            
            pendingUploads = YES;
        }
        else if(uploadInfo.uploadStatus != UploadInfoStatusFailed)
        {
            [self.allUploadsDictionary removeObjectForKey:uploadInfo.uuid];
        }
    }
    
    [self saveUploadsData];
    
    if(pendingUploads)
    {
        [self.uploadsQueue go];
    }
}

- (void)saveUploadsData
{
    NSString *uploadsStorePath = [FileUtils pathToConfigFile:self.configFile];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.allUploadsDictionary];
    [data writeToFile:uploadsStorePath atomically:YES];
    //Complete protection for uploads metadata
    [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:uploadsStorePath];
}

- (void)successUpload:(UploadInfo *)uploadInfo
{
    [uploadInfo setUploadStatus:UploadInfoStatusUploaded];
    
    //We don't manage successful uploads
    [self.allUploadsDictionary removeObjectForKey:uploadInfo.uuid];
    [self saveUploadsData];
    
}
- (void)failedUpload:(UploadInfo *)uploadInfo withError:(NSError *)error
{
    ODSLogTrace(@"Upload Failed for file %@ and uuid %@ with error: %@", [uploadInfo completeFileName], [uploadInfo uuid], error);
    [uploadInfo setUploadStatus:UploadInfoStatusFailed];
    [uploadInfo setError:error];
    [self saveUploadsData];
    
}

#pragma mark - Upload File Request Delegate Method
- (void)requestStarted:(CMISUploadRequest *)request
{
    UploadInfo *uploadInfo = [request uploadInfo];
    [uploadInfo setUploadStatus:UploadInfoStatusUploading];
    [self saveUploadsData];
}

- (void)requestFinished:(CMISUploadRequest *)request
{
    UploadInfo *uploadInfo = [request uploadInfo];
    ODSLogTrace(@"Successful upload for file %@ and uuid %@", [uploadInfo completeFileName], [uploadInfo uuid]);
    
    [uploadInfo setUploadRequest:nil];
    [self saveUploadsData];
    
    [self successUpload:uploadInfo];
    
    ODSLogTrace(@"Starting the Action Service extract-metadata request for file %@", [uploadInfo completeFileName]);
}

- (void)requestFailed:(CMISUploadRequest *)request
{
    UploadInfo *uploadInfo = [request uploadInfo];
    //reset upload progress.
    self.uploadsQueue.bytesUploadedSoFar -= uploadInfo.uploadRequest.sentBytes;
    self.uploadsQueue.totalBytesToUpload -= uploadInfo.uploadRequest.totalBytes;
    [uploadInfo setUploadRequest:nil];
    [self failedUpload:uploadInfo withError:request.error];  //TODO:not save the last error for request now.
}

- (void)requestQueueFinished:(ODSUploadQueue *)queue
{
    [queue cancelAllOperations];
}

@end
