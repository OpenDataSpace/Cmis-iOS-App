//
//  ODSDownloadQueue.m
//  ODS
//
//  Created by bdt on 10/5/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ODSDownloadQueue.h"
#import "CMISDownloadFileRequest.h"
#import "DownloadInfo.h"

@interface ODSDownloadQueue()
@property (assign) int requestsCount;
@property (assign) long long bytesOfFinished;
@property (assign) float progress;
@end

@implementation ODSDownloadQueue
@synthesize bytesDownloadedSoFar = _bytesDownloadedSoFar;
@synthesize totalBytesToDownload = _totalBytesToDownload;
@synthesize bytesOfFinished = _bytesOfFinished;
@synthesize requestsCount = _requestsCount;
@synthesize downloadProgressDelegate = _downloadProgressDelegate;
@synthesize delegate = _delegate;
@synthesize progress = _progress;

#pragma mark -
#pragma mark - Init
- (id)init
{
    if (self = [super init]) {
        [self setMaxConcurrentOperationCount:2];
        [self setSuspended:YES];
    }
    
    return self;
}

// Convenience constructor
+ (ODSDownloadQueue*) queue {
    return [[self alloc] init];
}

// This method will start the queue
- (void) go {
    [self setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self setBytesDownloadedSoFar:0];
    [self setTotalBytesToDownload:0];
    [self setBytesOfFinished:0];
    [self setProgress:0.0];
    [super cancelAllOperations];
}

- (void)addOperation:(NSOperation *)operation
{
    if (![operation isKindOfClass:[CMISDownloadFileRequest class]]) {
        [NSException raise:@"AttemptToAddInvalidRequest" format:@"Attempted to add an object that was not an CMISDownloadFileRequest to an ODSDownloadQueue."];
    }
    
    [self setRequestsCount:[self requestsCount] + 1];
    
    CMISDownloadFileRequest *request = (CMISDownloadFileRequest *)operation;
    
    [self setTotalBytesToDownload:[self totalBytesToDownload] + [request totalBytes]];
    
    ODSLogDebug(@"download total bytes:%lu", self.totalBytesToDownload);
    
    [request setQueue:self];
    
    [super addOperation:request];
}

#pragma mark -
#pragma mark - Upload File Request Delegate Method
- (void)requestStarted:(CMISDownloadFileRequest *)request
{
    if ([self requestDidStartSelector]) {
        [[self delegate] performSelector:[self requestDidStartSelector] withObject:request];  //should add -Wno-arc-performSelector-leaks
    }
}

- (void)requestFinished:(CMISDownloadFileRequest *)request
{
    [self setRequestsCount:[self requestsCount]-1];
    self.bytesOfFinished += request.totalBytes;
    if ([self requestDidFinishSelector]) {
        [[self delegate] performSelector:[self requestDidFinishSelector] withObject:request];
    }
    if ([self requestsCount] == 0) {
        if ([self queueDidFinishSelector]) {
            [[self delegate] performSelector:[self queueDidFinishSelector] withObject:self];
        }
    }
}

- (void)requestFailed:(CMISDownloadFileRequest *)request
{
    [self setRequestsCount:[self requestsCount]-1];
    self.bytesOfFinished += request.downloadedBytes;
    if ([self requestDidFailSelector]) {
        [[self delegate] performSelector:[self requestDidFailSelector] withObject:request];
    }
    if ([self requestsCount] == 0) {
        if ([self queueDidFinishSelector]) {
            [[self delegate] performSelector:[self queueDidFinishSelector] withObject:self];
        }
    }
}

- (void)request:(CMISDownloadFileRequest *)request downloadedBytes:(long long)bytes {
    [self performSelectorInBackground:@selector(updateDownloadProgress) withObject:self];
}

- (void) updateDownloadProgress {
    dispatch_main_sync_safe(^{
        UIProgressView *uploadIndicator = (UIProgressView *)_downloadProgressDelegate;
        if (uploadIndicator) {
            //update bytes downloaded
            long long downloadingBytes = 0;
            NSArray *operations = [self operations];
            for (CMISDownloadFileRequest *operation in operations ) {
                if (operation.downloadInfo.downloadStatus != DownloadInfoStatusDownloaded) {
                    downloadingBytes += operation.downloadedBytes;
                }
            }
            _bytesDownloadedSoFar = downloadingBytes + _bytesOfFinished;
            _progress = (_bytesDownloadedSoFar)*1.0f/_totalBytesToDownload;
            if (_totalBytesToDownload == 0 || _bytesDownloadedSoFar == 0) {
                ODSLogDebug(@"download progress:%lu ------ %lu ==== %f", _bytesDownloadedSoFar, _totalBytesToDownload, _progress);
            }
            
            [uploadIndicator setProgress:_progress];
        }
    });
}
@end
