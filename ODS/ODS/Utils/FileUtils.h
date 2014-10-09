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
//  FileUtils.h
//

@interface FileUtils : UIViewController

+ (BOOL)isSaved: (NSString *)filename;

// Save a temporary file to the downloads folder. Safe operation; overwrite=NO.
+ (BOOL)save: (NSString *)filename;

// Save a temporary file to the downloads folder with the given name. Safe operation; overwrite=NO.
+ (BOOL)saveTempFile:(NSString *)filename withName:(NSString *)name;

// Save a temporary file to the downloads folder with the given name. Optionally overwrite existing file.
+ (BOOL)saveTempFile:(NSString *)filename withName:(NSString *)name overwriteExisting:(BOOL)overwriteExisting;

// Save a file from a given source path to the downloads folder with a given filename. Safe operation; overwrite=NO.
+ (BOOL)saveFileToDownloads:(NSString *)source withName:(NSString *)name;

// Save a file from a given source path to the downloads folder with a given filename. Optionally overwrite existing file.
+ (NSString *)saveFileToDownloads:(NSString *)source withName:(NSString *)name overwriteExisting:(BOOL)allowSuffix;

// Save a file from a given location to a given destination. Safe operation; overwrite=NO.
+ (BOOL)saveFileFrom:(NSString *)source toDestination:(NSString *) dest;

// Save a file from a given location to a given destination. Optionally overwrite existing file.
+ (NSString *)saveFileFrom:(NSString *)source toDestination:(NSString *)dest overwriteExisting:(BOOL)overwriteExisting;

// Move a file to the temporary folder
+ (BOOL)moveFileToTemporaryFolder:(NSString *)source;

+ (BOOL)unsave:(NSString *)filename;
+ (NSArray *)list;
+ (NSArray *)listSyncedFiles;
+ (NSString *)pathToTempFile:(NSString *)filename;
+ (NSString *)pathToSavedFile:(NSString *)filename;
+ (NSString *)pathToConfigFile:(NSString *)filename;
+ (NSString *)pathToCacheFile:(NSString*)filename;
+ (NSString *)sizeOfSavedFile:(NSString *)filename;

+ (NSString *)stringForLongFileSize:(long)size;
+ (NSString *)stringForUnsignedLongLongFileSize:(unsigned long long)size;

+ (void)enumerateSavedFilesUsingBlock:(void(^)(NSString *))filesBlock;

+ (NSDate *)lastDownloadedDateForFile:(NSString *) filename;
/*
 Returns the next valid filename to avoid name crashing in a folder/repository node
 by adding a -{num} where {num} is the next available number that avoids a name conflict in the
 folder/repository node
 */
+ (NSString *)nextFilename:(NSString *)filename inNodeWithDocumentNames:(NSArray *)documentNames;
@end
