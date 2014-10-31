//
//  ODSDownloadQueue.h
//  ODS
//
//  Created by bdt on 10/5/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISDownloadFileRequest;
@interface ODSDownloadQueue : NSOperationQueue

@property (assign, nonatomic) id delegate;

@property (assign, nonatomic) unsigned long long bytesDownloadedSoFar;
@property (assign, nonatomic) unsigned long long totalBytesToDownload;

@property (assign, nonatomic) id    downloadProgressDelegate;

@property (strong, nonatomic) NSDictionary *userInfo;

@property (assign, nonatomic) SEL requestDidStartSelector;
@property (assign, nonatomic) SEL requestDidFinishSelector;
@property (assign, nonatomic) SEL requestDidFailSelector;
@property (assign, nonatomic) SEL queueDidFinishSelector;

+ (ODSDownloadQueue*) queue;

- (void) go;

- (void)requestStarted:(CMISDownloadFileRequest *)request;
- (void)requestFinished:(CMISDownloadFileRequest *)request;
- (void)requestFailed:(CMISDownloadFileRequest *)request;
- (void)request:(CMISDownloadFileRequest *)request downloadedBytes:(long long)bytes;
@end
