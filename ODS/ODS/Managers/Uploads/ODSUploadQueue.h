//
//  ODSUploadQueue.h
//  ODS
//
//  Created by bdt on 10/5/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISUploadRequest;

@interface ODSUploadQueue : NSOperationQueue

@property (assign, nonatomic) BOOL shouldCancelAllRequestsOnFailure;

@property (assign) unsigned long long bytesUploadedSoFar;
@property (assign) unsigned long long totalBytesToUpload;

@property (assign, nonatomic) id delegate;

@property (assign, nonatomic) id    uploadProgressDelegate;
@property (assign, nonatomic) id    downloadProgressDelegate;

@property (strong, nonatomic) NSDictionary *userInfo;

@property (assign, nonatomic) SEL requestDidStartSelector;
@property (assign, nonatomic) SEL requestDidFinishSelector;
@property (assign, nonatomic) SEL requestDidFailSelector;
@property (assign, nonatomic) SEL queueDidFinishSelector;

+ (ODSUploadQueue*) queue;

- (void) go;

- (void)requestStarted:(CMISUploadRequest *)request;
- (void)requestFinished:(CMISUploadRequest *)request;
- (void)requestFailed:(CMISUploadRequest *)request;
- (void)request:(CMISUploadRequest *)request didSendBytes:(long long)bytes;
@end
