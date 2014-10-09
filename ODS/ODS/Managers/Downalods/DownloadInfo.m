//
//  DownloadInfo.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadInfo.h"
#import "DownloadMetadata.h"

@implementation DownloadInfo
@synthesize tempFilePath = _tempFilePath;
@synthesize downloadFileURL = _downloadFileURL;
@synthesize selectedAccountUUID = _selectedAccountUUID;
@synthesize tenantID = _tenantID;
@synthesize downloadStatus = _downloadStatus;
@synthesize downloadRequest = _downloadRequest;
@synthesize error = _error;

- (DownloadMetadata *)downloadMetadata
{
    //RepositoryInfo *repoInfo = [[RepositoryServices shared] getRepositoryInfoForAccountUUID:self.selectedAccountUUID tenantID:self.tenantID];
    
    DownloadMetadata *downloadMetadata = [[DownloadMetadata alloc] init];
    //downloadMetadata.filename = self.repositoryItem.title;
    downloadMetadata.accountUUID = self.selectedAccountUUID;
    downloadMetadata.tenantID = self.tenantID;
    downloadMetadata.objectId = self.cmisObjectId;
//    downloadMetadata.contentStreamMimeType = [self.repositoryItem.metadata objectForKey:@"cmis:contentStreamMimeType"]; // TODO Constants
//    downloadMetadata.versionSeriesId = self.repositoryItem.versionSeriesId;
//    downloadMetadata.repositoryId = repoInfo.repositoryId;
//    downloadMetadata.metadata = self.repositoryItem.metadata;
//    downloadMetadata.aspects = self.repositoryItem.aspects;
//    downloadMetadata.describedByUrl = self.repositoryItem.describedByURL;
//    downloadMetadata.contentLocation = self.repositoryItem.contentLocation;
//    downloadMetadata.linkRelations = self.repositoryItem.linkRelations;
//    downloadMetadata.canSetContentStream = self.repositoryItem.canSetContentStream;
    
    return downloadMetadata;
}

- (NSString *)cmisObjectId
{
    return self.cmisObjectId;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"DownloadInfo: %@, objectId: %@, status %u", [self class], self.cmisObjectId, self.downloadStatus];
}

@end
