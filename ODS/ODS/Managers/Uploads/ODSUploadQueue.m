//
//  ODSUploadQueue.m
//  ODS
//
//  Created by bdt on 10/5/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ODSUploadQueue.h"
#import "CMISUploadRequest.h"

@interface ODSUploadQueue()
@property (assign) int requestsCount;
@property (assign) long long bytesOfFinished;
@property (assign) float progress;
@end

@implementation ODSUploadQueue
@synthesize requestsCount = _requestsCount;
@synthesize bytesOfFinished = _bytesOfFinished;
@synthesize progress = _progress;

#pragma mark -
#pragma mark - Init
- (id)init
{
    if (self = [super init]) {
        [self setShouldCancelAllRequestsOnFailure:YES];
        [self setMaxConcurrentOperationCount:2];
        [self setSuspended:YES];
    }
    
    return self;
}

// Convenience constructor
+ (ODSUploadQueue*) queue {
    return [[self alloc] init];
}

// This method will start the queue
- (void) go {
    [self setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self setBytesUploadedSoFar:0];
    [self setTotalBytesToUpload:0];
    [self setBytesOfFinished:0];
    [super cancelAllOperations];
}

- (void)addOperation:(NSOperation *)operation
{
    if (![operation isKindOfClass:[CMISUploadRequest class]]) {
        [NSException raise:@"AttemptToAddInvalidRequest" format:@"Attempted to add an object that was not an CMISUploadRequest to an ODSUploadQueue."];
    }
    
    [self setRequestsCount:[self requestsCount] + 1];
    
    CMISUploadRequest *request = (CMISUploadRequest *)operation;
    
    [self setTotalBytesToUpload:[self totalBytesToUpload] + [request totalBytes]];
    
    
    [request setQueue:self];
    
    [super addOperation:request];
}

#pragma mark -
#pragma mark - Upload File Request Delegate Method
- (void)requestStarted:(CMISUploadRequest *)request
{
    if ([self requestDidStartSelector]) {
        [[self delegate] performSelector:[self requestDidStartSelector] withObject:request];  //should add -Wno-arc-performSelector-leaks
    }
}

- (void)requestFinished:(CMISUploadRequest *)request
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

- (void)requestFailed:(CMISUploadRequest *)request
{
    [self setRequestsCount:[self requestsCount]-1];
    self.bytesOfFinished += request.sentBytes;
    if ([self requestDidFailSelector]) {
        [[self delegate] performSelector:[self requestDidFailSelector] withObject:request];
    }
    if ([self requestsCount] == 0) {
        if ([self queueDidFinishSelector]) {
            [[self delegate] performSelector:[self queueDidFinishSelector] withObject:self];
        }
    }
    if ([self shouldCancelAllRequestsOnFailure] && [self requestsCount] > 0) {
        [self cancelAllOperations];
    }
}

- (void)request:(CMISUploadRequest *)request didSendBytes:(long long)bytes {
    [self performSelectorInBackground:@selector(updateUploadProgress) withObject:self];
}

- (void) updateUploadProgress {
    dispatch_main_sync_safe(^{
        UIProgressView *uploadIndicator = (UIProgressView *)_uploadProgressDelegate;
        if (uploadIndicator) {
            //update bytes downloaded
            long long uploadedBytes = 0;
            NSArray *operations = [self operations];
            for (CMISUploadRequest *operation in operations ) {
                if (operation.uploadInfo.uploadStatus != UploadInfoStatusUploaded) {
                    uploadedBytes += operation.sentBytes;
                }
            }
            _bytesUploadedSoFar = uploadedBytes + _bytesOfFinished;
            _progress = (_bytesUploadedSoFar)*1.0f/_totalBytesToUpload;
            
            [uploadIndicator setProgress:_progress];
        }
    });
}

@end
