//
//  ODSBaseRequest.m
//  ODS
//
//  Created by bdt on 10/4/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ODSBaseRequest.h"

@implementation ODSBaseRequest

- (id) init {
    if (self = [super init]) {
        self.downloadProgressDelegate = nil;
        self.uploadProgressDelegate = nil;
        self.currentRequest = nil;
        self.error = nil;
        
        self.downloadedBytes = 0;
        self.sentBytes = 0;
        self.totalBytes = 0;
        
        self.cancelledLock = [[NSRecursiveLock alloc] init];
        
        self.bytesReceivedBlock = nil;
        self.bytesSentBlock = nil;
    }
    
    return self;
}

- (void) clearDelegatesAndCancel {
    self.downloadProgressDelegate = nil;
    self.uploadProgressDelegate = nil;
    self.currentRequest = nil;
    
    [self cancel];
}

@end
