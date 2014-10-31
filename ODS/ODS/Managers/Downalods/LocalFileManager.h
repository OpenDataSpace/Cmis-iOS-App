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

- (BOOL) downloadExistsForKey:(NSString *)key;
- (BOOL) downloadExistsForFileObject:(CMISObject*) fileObj;

//objectid (cmisobjectId + fileName) as key
- (NSString *)setDownload:(NSDictionary *)downloadInfo forKey:(NSString *)key withFilePath:(NSString *)tempFile;
- (NSString *)setDownload:(NSDictionary *)downloadInfo forKey:(NSString *)key;

- (NSDictionary *)downloadInfoForDocumentWithKey:(NSString *)key;

- (BOOL)removeDownloadInfoForKey:(NSString *)key;
- (void)removeDownloadInfoForAllFiles;

- (NSMutableDictionary *) readMetadata;
- (BOOL) writeMetadata;

+ (LocalFileManager *)sharedInstance;
+ (NSString*) downloadKeyWithObjectID:(NSString*) cmisObjectId withFileName:(NSString*) fileName;
+ (NSString*) downloadKeyWithObject:(CMISObject*) fileObj;
@end
