//
//  AbstractUploadsManager.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODSUploadQueue.h"
#import "CMISUploadRequest.h"

#import "UploadInfo.h"
#import "NSNotificationCenter+CustomNotification.h"

@interface AbstractUploadsManager : NSObject

@property (nonatomic, strong, readonly) ODSUploadQueue *uploadsQueue;

@property (nonatomic, copy) NSString * configFile;

// Returns all the current uploads managed by this object
- (NSArray *)allUploads;

// Returns all the active uploads managed by this object
- (NSArray *)activeUploads;

// Returns all the failed uploads managed by this object
- (NSArray *)failedUploads;

- (BOOL)isManagedUpload:(NSString *)uuid;

// Adds an upload to the uploads queue and will be part of the uploads managed by the
// Uploads Manager
- (void)queueUpload:(UploadInfo *)uploadInfo;
// Adds an aray of upload infos to the uploads queue and will be part of the uploads managed by the
// Uploads Manager
- (void)queueUploadArray:(NSArray *)uploads;

-(void) queueUpdateUpload:(UploadInfo *)uploadInfo;

// Deletes the upload from the upload datasource.
- (void)clearUpload:(NSString *)uploadUUID;
// Deletes an array of uploads upload datasource.
- (void)clearUploads:(NSArray *)uploads;
// Tries to cancel and delete the active uploads
- (void)cancelActiveUploads;
// Tries to retry an upload. returns YES if sucessful, NO if there was a problem (upload file missing, upload no longer managed)
- (BOOL)retryUpload:(NSString *)uploadUUID;

- (void)cancelActiveUploadsForAccountUUID:(NSString *)accountUUID;

@property (nonatomic, strong) NSMutableDictionary *allUploadsDictionary;
@property (nonatomic, strong) dispatch_queue_t addUploadQueue; //It's an  Obj-C objects for deploying to iOS 6.0 or higher
- (void)initQueue;
- (void)saveUploadsData;
- (void)successUpload:(UploadInfo *)uploadInfo;
- (void)failedUpload:(UploadInfo *)uploadInfo withError:(NSError *)error;

- (void)requestStarted:(CMISUploadRequest *)request;
- (void)requestFinished:(CMISUploadRequest *)request;
- (void)requestFailed:(CMISUploadRequest *)request;
- (void)requestQueueFinished:(ODSUploadQueue *)queue;

- (id)initWithConfigFile:(NSString *)file andUploadQueue:(NSString *) queue;
@end
