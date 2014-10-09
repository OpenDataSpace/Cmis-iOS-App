//
//  ODSDownloadQueue.m
//  ODS
//
//  Created by bdt on 10/5/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ODSDownloadQueue.h"
#import "CMISDownloadFileRequest.h"


@interface ODSDownloadQueue()
@property (assign) int requestsCount;
@end

@implementation ODSDownloadQueue

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
    //update bytes downloaded
}
@end
