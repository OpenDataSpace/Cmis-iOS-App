/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  FileUtils.m
//

#import "FileUtils.h"
#import "FileProtectionManager.h"
#import "NSArray+Utils.h"

@interface FileUtils ()
+ (NSString *)safeFilenameForDestination:(NSString *)destination;
@end

@implementation FileUtils

+ (BOOL)isSaved:(NSString *)filename
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[FileUtils pathToSavedFile:filename]];
}

/**
 * Save a temporary file to the downloads folder. Safe operation; overwrite=NO.
 */
+ (BOOL)save:(NSString *)filename
{
    return [FileUtils saveTempFile:filename withName:filename];
}

/**
 * Save a temporary file to the downloads folder with the given name. Safe operation; overwrite=NO.
 */
+ (BOOL)saveTempFile:(NSString *)filename withName:(NSString *)name
{
    return [FileUtils saveFileToDownloads:[FileUtils pathToTempFile:filename] withName:name];
}

/**
 * Save a temporary file to the downloads folder with the given name. Optionally overwrite existing file.
 */
+ (BOOL)saveTempFile:(NSString *)filename withName:(NSString *)name overwriteExisting:(BOOL)overwriteExisting
{
    return [FileUtils saveFileToDownloads:[FileUtils pathToTempFile:filename] withName:name overwriteExisting:overwriteExisting] != nil;
}

/**
 * Save a file from a given source path to the downloads folder with a given filename. Safe operation; overwrite=NO.
 */
+ (BOOL)saveFileToDownloads:(NSString *)source withName:(NSString *)name
{
    return ([FileUtils saveFileToDownloads:source withName:name overwriteExisting:NO] != nil);
}

/**
 * Save a file from a given source path to the downloads folder with a given filename. Optionally overwrite existing file.
 */
+ (NSString *)saveFileToDownloads:(NSString *)source withName:(NSString *)name overwriteExisting:(BOOL)overwriteExisting
{
	// the destination is in the documents dir
	NSString *destination = [NSString stringWithString:[FileUtils pathToSavedFile:name]];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;

    if (overwriteExisting)
    {
        if ([manager fileExistsAtPath:destination])
        {
            [manager removeItemAtPath:destination error:&error];
        }
    }
    else
    {
        destination = [FileUtils safeFilenameForDestination:destination];
        if (destination == nil)
        {
            return NO;
        }
    }
    
    BOOL success = [manager copyItemAtPath:source toPath:destination error:&error];
    
    if (!success)
    {
        ODSLogError(@"Failed to create file %@, with error: %@", destination, [error description]);
    }
    else
    {
        success = [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:destination];
        if (!success)
        {
            ODSLogError(@"Failed to protect file %@, with error: %@", destination, [error description]);
        }
    }
    
    return success ? destination : nil;
}

/**
 * Save a file from a given location to a given destination. Safe operation; overwrite=NO.
 */
+ (BOOL)saveFileFrom:(NSString *)source toDestination:(NSString *)dest
{
    return [self saveFileFrom:source toDestination:dest overwriteExisting:NO] != nil;
}

/**
 * Save a file from a given location to a given destination. Optionally overwrite existing file.
 */
+ (NSString *)saveFileFrom:(NSString *)source toDestination:(NSString *)destination overwriteExisting:(BOOL)overwriteExisting
{
    if ([source isEqualToString:destination])
    {
        return destination;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;

    if (![manager fileExistsAtPath:source])
    {
        return nil;
    }

    if (overwriteExisting)
    {
        if ([manager fileExistsAtPath:destination])
        {
            [manager removeItemAtPath:destination error:&error];
        }
    }
    else
    {
        destination = [FileUtils safeFilenameForDestination:destination];
        if (destination == nil)
        {
            return nil;
        }
    }
    
    BOOL success = [manager copyItemAtPath:source toPath:destination error:&error];
    if (!success)
    {
        ODSLogError(@"Failed to create file %@, with error: %@", destination, [error description]);
    }
    else
    {
        success = [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:destination];
        if (!success)
        {
            ODSLogError(@"Failed to protect file %@, with error: %@", destination, [error description]);
        }
    }
    
    return success ? destination : nil;
}

+ (NSString *)safeFilenameForDestination:(NSString *)destination
{
    NSFileManager *manager = [NSFileManager defaultManager];
    // We'll bail out after kFileSuffixMaxAttempts attempts
    unsigned int suffix = 0;
    NSString *path = [destination stringByDeletingLastPathComponent];
    NSString *filenameWithoutExtension = [destination.lastPathComponent stringByDeletingPathExtension];
    NSString *fileExtension = [destination pathExtension];
    if (fileExtension == nil || [fileExtension isEqualToString:@""])
    {
        while ([manager fileExistsAtPath:destination] && (++suffix < kFileSuffixMaxAttempts))
        {
            destination = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%u", filenameWithoutExtension, suffix]];
        }
    }
    else
    {
        while ([manager fileExistsAtPath:destination] && (++suffix < kFileSuffixMaxAttempts))
        {
            destination = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%u.%@", filenameWithoutExtension, suffix, fileExtension]];
        }
    }
    
    // Did we hit the max suffix number?
    if (suffix == kFileSuffixMaxAttempts)
    {
        ODSLogError(@"ERROR: Couldn't save downloaded file as kFileSuffixMaxAttempts (%u) reached", kFileSuffixMaxAttempts);
        return nil;
    }
    
    return destination;
}

+ (BOOL)moveFileToTemporaryFolder:(NSString *)source
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:source])
    {
        NSString *destination = [FileUtils pathToTempFile:[source lastPathComponent]];
        
        if ([source isEqualToString:destination])
        {
            return YES;
        }
        
        NSError *error = nil;
        if ([manager fileExistsAtPath:destination])
        {
            [manager removeItemAtPath:destination error:&error];
        }
        if (!error)
        {
            [manager moveItemAtPath:source toPath:destination error:&error];
            if (!error)
            {
                return YES;
            }
        }
    
    }
    return NO;
}

// aka "delete" :)
+ (BOOL)unsave:(NSString *)filename
{
	NSError *error = nil;
	
	[[NSFileManager defaultManager] removeItemAtPath:[FileUtils pathToSavedFile:filename] error:&error];
    
    if (error)
    {
        ODSLogError(@"Error: %@ deleting file: %@", [error description], filename);
        return NO;
    }
    
    return YES;
}

+ (NSArray *)list
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths objectAtIndex:0];
	NSError *error = nil;
	
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:&error];
}

+ (NSArray *)listSyncedFiles
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths objectAtIndex:0];
    NSString *favDir = [docDir stringByAppendingPathComponent:kSyncedFilesDirectory];
	NSError *error = nil;
	
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:favDir error:&error];
}

+ (NSString *)pathToSavedFile:(NSString *)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths objectAtIndex:0];
    NSString *favDir = [docDir stringByAppendingPathComponent:kSyncedFilesDirectory];
	NSString *path = [docDir stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory; 

    if(![fileManager fileExistsAtPath:docDir isDirectory:&isDirectory] || !isDirectory)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error)
        {
            ODSLogError(@"Error creating the %@ folder: %@", @"Documents", [error description]);
            return  nil;
        }
    }
    
    if (![fileManager fileExistsAtPath:favDir isDirectory:&isDirectory] || !isDirectory)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:favDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error)
        {
            ODSLogError(@"Error creating the %@ folder: %@", @"Documents", [error description]);
            return  nil;
        }
    }
    
	return path;
}

+ (NSString *)pathToTempFile:(NSString *)filename
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:[filename lastPathComponent]];
}

+ (NSString *)pathToConfigFile:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *configDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:kFDLibraryConfigFolderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory; 
    
    if (![fileManager fileExistsAtPath:configDir isDirectory:&isDirectory] || !isDirectory)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:configDir withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error)
        {
            ODSLogError(@"Error creating the %@ folder: %@", kFDLibraryConfigFolderName, [error description]);
            return  nil;
        }
    }
    
    NSString *path = [configDir stringByAppendingPathComponent:filename];
    return path;
}

+ (NSString *)pathToCacheFile:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *cacheDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PreviewCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:cacheDir isDirectory:&isDirectory] || !isDirectory)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error)
        {
            ODSLogError(@"Error creating the %@ folder: %@", kFDLibraryConfigFolderName, [error description]);
            return  nil;
        }
    }
    
    NSString *path = [cacheDir stringByAppendingPathComponent:filename];
    return path;
}

+ (NSString *)sizeOfSavedFile:(NSString *)filename
{
	NSError *error = nil;
	NSString *path = [FileUtils pathToSavedFile:filename];
	NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
	
	return [FileUtils stringForLongFileSize:[[attrs objectForKey:NSFileSize] longValue]];
}

+ (NSString *)pathToLogoFile:(NSString*) filename accountUUID:(NSString*) acctUUID {
    NSString *configDir = [NSTemporaryDirectory() stringByAppendingPathComponent:acctUUID];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:configDir isDirectory:&isDirectory] || !isDirectory)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:configDir withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error)
        {
            ODSLogError(@"Error creating the %@ folder: %@", acctUUID, [error description]);
            return  nil;
        }
    }
    
    NSString *path = [configDir stringByAppendingPathComponent:filename];
    return path;
}

+ (NSString *)stringForLongFileSize:(long)size
{
	float floatSize = size;
	if (size < 1023)
    {
		return([NSString stringWithFormat:@"%ld %@", size, NSLocalizedString(@"bytes", @"file bytes, used as follows: '100 bytes'")]);
    }
    
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
    {
		return([NSString stringWithFormat:@"%1.1f %@",floatSize, NSLocalizedString(@"kb", @"Abbreviation for Kilobytes, used as follows: '17KB'")]);
    }

	floatSize = floatSize / 1024;
	if (floatSize < 1023)
    {
		return([NSString stringWithFormat:@"%1.1f %@",floatSize, NSLocalizedString(@"mb", @"Abbreviation for Megabytes, used as follows: '2MB'")]);
    }

	floatSize = floatSize / 1024;
	
	// Add as many as you like

	return ([NSString stringWithFormat:@"%1.1f %@",floatSize, NSLocalizedString(@"GB", @"Abbrevation for Gigabyte, used as follows: '1GB'")]);
}

+ (NSString *)stringForUnsignedLongLongFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;
    if (size == 0)
    {
		formattedStr = @"Empty";
    }
	else
    {
		if (size > 0 && size < 1024)
        {
			formattedStr = [NSString stringWithFormat:@"%qu %@", size, NSLocalizedString(@"bytes", @"file bytes, used as follows: '100 Bytes'")];
        }
        else
        {
            if (size >= 1024 && size < pow(1024, 2))
            {
                formattedStr = [NSString stringWithFormat:@"%.1f %@", (size / 1024.), NSLocalizedString(@"kb", @"Abbreviation for Kilobytes, used as follows: '17 KB'")];
            }
            else
            {
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                {
                    formattedStr = [NSString stringWithFormat:@"%.2f %@", (size / pow(1024, 2)), NSLocalizedString(@"mb", @"Abbreviation for Megabytes, used as follows: '2 MB'")];
                }
                else
                {
                    if (size >= pow(1024, 3))
                    {
                        formattedStr = [NSString stringWithFormat:@"%.3f %@", (size / pow(1024, 3)), NSLocalizedString(@"gb", @"Abbrevation for Gigabyte, used as follows: '1 GB'")];
                    }
                }
            }
        }
    }
	
	return formattedStr;
}

+ (NSArray *)allSavedFilePaths
{
    NSMutableArray *savedFiles = [NSMutableArray array];
    NSString *folderPath = [self pathToSavedFile:@""];
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:NULL];
    
    for (NSString *fileName in [folderContents objectEnumerator])
    {
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // only add files, no directories nor the Inbox
        if (!isDirectory && ![fileName isEqualToString: @"Inbox"])
        {
            [savedFiles addObject:filePath];
        }
    }
    
    return [NSArray arrayWithArray:savedFiles];
}

+ (void)enumerateSavedFilesUsingBlock:(void(^)(NSString *))filesBlock
{
    for (NSString *path in [self allSavedFilePaths])
    {
        filesBlock(path);
    }
}

+ (NSString *)nextFilename:(NSString *)filename inNodeWithDocumentNames:(NSArray *)documentNames
{
    int ct = 0;
    NSString *extension = [filename pathExtension];
    
    NSString *originalName = [filename stringByDeletingPathExtension];
    NSString *newName = [originalName copy];
    NSString *finalFilename = nil;
  
    if (extension == nil || [extension isEqualToString:@""])
    {
        while ([documentNames containsString:newName caseInsensitive:YES])
        {
            ODSLogTrace(@"File with name %@ exists, incrementing and trying again", newName);
            newName = [[NSString alloc] initWithFormat:@"%@-%d", originalName, ++ct];
        }
        finalFilename = [newName copy];
    }
    else 
    {
        while ([documentNames containsString:[newName stringByAppendingPathExtension:extension] caseInsensitive:YES])
        {
            ODSLogTrace(@"File with name %@ exists, incrementing and trying again", newName);

            newName = [[NSString alloc] initWithFormat:@"%@-%d", originalName, ++ct];
        }
        finalFilename = [newName stringByAppendingPathExtension:extension];
    }

    return finalFilename;
}

+ (NSDate *) lastDownloadedDateForFile:(NSString *) filename
{
    NSError *error = nil;
	NSString *path = [FileUtils pathToSavedFile:filename];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];

    return [fileAttributes objectForKey:NSFileModificationDate];
}

@end
