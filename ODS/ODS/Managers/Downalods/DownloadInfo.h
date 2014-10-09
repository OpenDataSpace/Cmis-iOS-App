//
//  DownloadInfo.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadMetadata;
@class CMISDownloadFileRequest;

typedef enum
{
    DownloadInfoStatusInactive,
    DownloadInfoStatusActive,
    DownloadInfoStatusDownloading,
    DownloadInfoStatusDownloaded,
    DownloadInfoStatusFailed
} DownloadInfoStatus;

@interface DownloadInfo : NSObject

@property (nonatomic, copy) NSString *tempFilePath;
@property (nonatomic, copy) NSURL *downloadFileURL;
@property (nonatomic, copy) NSString *selectedAccountUUID;
@property (nonatomic, copy) NSString *tenantID;
@property (nonatomic, readonly) DownloadMetadata *downloadMetadata;
@property (nonatomic, readonly) NSString *cmisObjectId;
@property (nonatomic, copy) NSString *repositoryIdentifier;

@property (nonatomic, assign) DownloadInfoStatus downloadStatus;
@property (nonatomic, retain) CMISDownloadFileRequest *downloadRequest;
@property (nonatomic, retain) NSError *error;

@end
