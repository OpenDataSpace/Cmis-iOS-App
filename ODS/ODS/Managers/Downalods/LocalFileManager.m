//
//  LocalFileManager.m
//  ODS
//
//  Created by bdt on 10/15/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "LocalFileManager.h"
#import "FileUtils.h"
#import "FileProtectionManager.h"
#import "NSNotificationCenter+CustomNotification.h"
#import "DownloadMetadata.h"

#import "CMISSession.h"

NSString * const MetadataFileName = @"DownloadMetadata.plist";

@interface LocalFileManager() {
    NSMutableDictionary *downloadMetadata;
}
@end

@implementation LocalFileManager

- (id)init {
    if (self = [super init])
    {
        self.overwriteExistingDownloads = NO;
        self.metadataConfigFileName = MetadataFileName;
    }
    return self;
}

- (BOOL) downloadExistsForKey:(NSString *)key {
    return [[NSFileManager defaultManager] fileExistsAtPath:[FileUtils pathToSavedFile:key]];
}

- (BOOL) downloadExistsForFileObject:(CMISObject*) fileObj {
    return [[NSFileManager defaultManager] fileExistsAtPath:[LocalFileManager downloadKeyWithObject:fileObj]];
}


//objectid (repositoryId + cmisobjectId) as key
- (NSString *)setDownload:(NSDictionary *)downloadInfo forKey:(NSString *)key {
    [[self readMetadata] setObject:downloadInfo forKey:key];
    
    if (![self writeMetadata])
    {
        ODSLogDebug(@"Cannot save the metadata plist");
        return nil;
    }
    return key;
}

- (NSString *)setDownload:(NSDictionary *)downloadInfo forKey:(NSString *)key withFilePath:(NSString *)tempFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!tempFile || ![fileManager fileExistsAtPath:[FileUtils pathToTempFile:tempFile]])
    {
        return nil;
    }
    
    NSDictionary *previousInfo = [[self readMetadata] objectForKey:key];
    
    if (![FileUtils saveTempFile:tempFile withName:key overwriteExisting:self.overwriteExistingDownloads])
    {
        ODSLogDebug(@"Cannot move tempFile: %@ to the downloadFolder, newName: %@", tempFile, key);
        return nil;
    }
    
    // Saving a legacy file or a document sent through document interaction
    if (downloadInfo)
    {
        NSMutableDictionary *tempDownloadInfo = [downloadInfo mutableCopy];
        [tempDownloadInfo setObject:[NSDate date] forKey:@"lastDownloadedDate"];
        [[self readMetadata] setObject:tempDownloadInfo forKey:key];
        if (![self writeMetadata])
        {
            [FileUtils unsave:key];
            [[self readMetadata] setObject:previousInfo forKey:key];
            ODSLogDebug(@"Cannot save the metadata plist");
            return nil;
        }
        else
        {
            NSURL *fileURL = [NSURL fileURLWithPath:[FileUtils pathToSavedFile:key]];
            addSkipBackupAttributeToItemAtURL(fileURL);
        }
    }
    return key;
}

- (NSDictionary *)downloadInfoForDocumentWithKey:(NSString *)key {
    [self readMetadata];
    
    return [downloadMetadata objectForKey:key];
}

- (BOOL)removeDownloadInfoForKey:(NSString *)key {
    NSDictionary *previousInfo = [[self readMetadata] objectForKey:key];
    
    if ([FileUtils moveFileToTemporaryFolder:[FileUtils pathToSavedFile:key]])
    {
        // If we can get an objectId, then notify interested parties that the file has moved
        NSString *objectId = [previousInfo objectForKey:@"objectId"];
        if (objectId)
        {
            NSDictionary *userInfo = @{@"objectId": objectId,
                                       @"newPath": [FileUtils pathToTempFile:key]
                                       };
            [[NSNotificationCenter defaultCenter] postDocumentUpdatedNotificationWithUserInfo:userInfo];
        }
        
        if (previousInfo)
        {
            [[self readMetadata] removeObjectForKey:key];
            
            if (![self writeMetadata])
            {
                ODSLogDebug(@"Cannot delete the metadata in the plist");
                return NO;
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (void)removeDownloadInfoForAllFiles {
    ODSLogDebug(@"Not implement it yet!");
}

- (NSMutableDictionary *) readMetadata {
    NSString *path = [self metadataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // We create an empty NSMutableDictionary if the file doesn't exists otherwise
    // we create it from the file
    if ([fileManager fileExistsAtPath:path])
    {
        NSError *error = nil;
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        
        //We assume the stored data must be a dictionary
        downloadMetadata = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListMutableContainers format:NULL error:&error];
        
        if (!downloadMetadata)
        {
            ODSLogDebug(@"Error reading plist from file '%@', error = '%@'", path, error.localizedDescription);
        }
    }
    else
    {
        downloadMetadata = [[NSMutableDictionary alloc] init];
    }
    
    return downloadMetadata;
}

- (BOOL) writeMetadata {
    NSString *path = [self metadataPath];
    NSError *error = nil;
    NSData *binaryData = [NSPropertyListSerialization dataWithPropertyList:downloadMetadata format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if (binaryData)
    {
        [binaryData writeToFile:path atomically:YES];
        //Complete protection in metadata since the file is always read one time and we write it when the application is active
        [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:path];
    }
    else
    {
        ODSLogDebug(@"Error writing plist to file '%@', error = '%@'", path, error.localizedDescription);
        return NO;
    }
    
    return YES;
}

- (NSString *)metadataPath {
    return [FileUtils pathToConfigFile:self.metadataConfigFileName];
}

#pragma mark - Singleton methods

+ (LocalFileManager *)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

+ (NSString*) downloadKeyWithObjectID:(NSString*) cmisObjectId withFileName:(NSString*) fileName {
    return [NSString stringWithFormat:@"%@_%@", cmisObjectId, fileName];
}

+ (NSString*) downloadKeyWithObject:(CMISObject*) fileObj {
    return [LocalFileManager downloadKeyWithObjectID:fileObj.identifier withFileName:fileObj.name];
}
@end
