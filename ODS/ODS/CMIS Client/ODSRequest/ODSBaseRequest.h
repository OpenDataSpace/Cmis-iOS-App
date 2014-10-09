//
//  ODSBaseRequest.h
//  ODS
//
//  Created by bdt on 10/4/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISRequest;
@class ODSBaseRequest;

typedef void (^ODSProgressBlock)(unsigned long long size, unsigned long long total);

@interface ODSBaseRequest : NSOperation

@property (assign, nonatomic) id                uploadProgressDelegate;
@property (assign, nonatomic) id                downloadProgressDelegate;
@property (strong, nonatomic) CMISRequest       *currentRequest;
@property (strong, nonatomic) NSError           *error;
@property (assign, nonatomic) BOOL              complete;
@property (strong, nonatomic) NSRecursiveLock   *cancelledLock;

@property (nonatomic, assign) uint64_t    totalBytes;
@property (nonatomic, assign) uint64_t    sentBytes;
@property (nonatomic, assign) uint64_t    downloadedBytes;

@property (nonatomic, assign) ODSProgressBlock  bytesReceivedBlock;
@property (nonatomic, assign) ODSProgressBlock  bytesSentBlock;

- (void) clearDelegatesAndCancel;

@end
