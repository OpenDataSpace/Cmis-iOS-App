//
//  LocalFileManager.h
//  ODS
//
//  Created by bdt on 10/15/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadInfo;

@interface LocalFileManager : NSObject

@property (nonatomic, assign) BOOL overwriteExistingDownloads;
@property (nonatomic, retain) NSString *metadataConfigFileName;

- (BOOL) downloadExistsForObjectID:(NSString *)objectID;
- (BOOL) downloadExistsForFileObject:(CMISObject*) fileObj;

//objectid (repositoryId + cmisobjectId) as key
- (NSString *)setDownload:(NSDictionary *)downloadInfo forKey:(NSString *)key withFilePath:(NSString *)tempFile;
- (NSString *)setDownload:(NSDictionary *)downloadInfo forKey:(NSString *)key;

- (NSDictionary *)downloadInfoForDocumentWithID:(NSString *)objectID;

- (BOOL)removeDownloadInfoForFileObjectID:(NSString *)objectID;
- (void)removeDownloadInfoForAllFiles;

- (NSMutableDictionary *) readMetadata;
- (BOOL) writeMetadata;

+ (LocalFileManager *)sharedInstance;
+ (NSString*) objectIDFromFileObject:(CMISObject*) fileObj;
+ (NSString*) objectIDFromFileObject:(CMISObject*) fileObj withRepositoryId:(NSString*)repositoryId;
@end
