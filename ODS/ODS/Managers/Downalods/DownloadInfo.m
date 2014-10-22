//
//  DownloadInfo.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadInfo.h"
#import "DownloadMetadata.h"
#import "CMISObject.h"
#import "FileUtils.h"
#import "LocalFileManager.h"

@implementation DownloadInfo
@synthesize repositoryItem = _repositoryItem;
@synthesize tempFilePath = _tempFilePath;
@synthesize downloadFileURL = _downloadFileURL;
@synthesize selectedAccountUUID = _selectedAccountUUID;
@synthesize tenantID = _tenantID;
@synthesize downloadStatus = _downloadStatus;
@synthesize downloadRequest = _downloadRequest;
@synthesize error = _error;
@synthesize cmisObjectId = _cmisObjectId;

- (DownloadMetadata *)downloadMetadata
{
    //RepositoryInfo *repoInfo = [[RepositoryServices shared] getRepositoryInfoForAccountUUID:self.selectedAccountUUID tenantID:self.tenantID];
    
    DownloadMetadata *downloadMetadata = [[DownloadMetadata alloc] init];
    downloadMetadata.filename = _repositoryItem.name;
    downloadMetadata.accountUUID = _selectedAccountUUID;
    downloadMetadata.tenantID = _tenantID;
    downloadMetadata.objectId = _repositoryItem.identifier;
//    downloadMetadata.contentStreamMimeType = [_repositoryItem.properties objectForKey:@"cmis:contentStreamMimeType"]; // TODO Constants
//    downloadMetadata.versionSeriesId = [NSString stringWithFormat:@"%d", _repositoryItem];
//    downloadMetadata.repositoryId = repoInfo.repositoryId;
//    downloadMetadata.metadata = self.repositoryItem;
//    downloadMetadata.aspects = self.repositoryItem.aspects;
//    downloadMetadata.describedByUrl = self.repositoryItem.describedByURL;
//    downloadMetadata.contentLocation = self.repositoryItem.contentLocation;
//    downloadMetadata.linkRelations = self.repositoryItem.linkRelations;
//    downloadMetadata.canSetContentStream = self.repositoryItem.canSetContentStream;
    
    return downloadMetadata;
}

- (NSString *)cmisObjectId
{
    return _cmisObjectId;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"DownloadInfo: %@, objectId: %@, status %u", [self class], self.cmisObjectId, self.downloadStatus];
}

- (id)initWithRepositoryItem:(CMISObject *)repositoryItem  withAcctUUID:(NSString*)acctUUID withRepositoryID:(NSString*)repositoryID withTenantID:(NSString*) tenantID {
    self = [super init];
    if (self)
    {
        _selectedAccountUUID = acctUUID;
        _tenantID = tenantID;
        _repositoryIdentifier = repositoryID;
        [self setRepositoryItem:repositoryItem];
    }
    return self;
}

- (void)setRepositoryItem:(CMISObject *)repositoryItem
{
    _repositoryItem = repositoryItem;
    
    _cmisObjectId = _repositoryItem.identifier;
    
    if (repositoryItem != nil) //TODO: Have the same cmis object id on server?
    {
        [self setTempFilePath:[FileUtils pathToTempFile:[LocalFileManager objectIDFromFileObject:_repositoryItem withRepositoryId:_repositoryIdentifier]]];
    }
}

@end
