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
 *
 * ***** END LICENSE BLOCK ***** */
//
//  ODSSaveBackAPI.m
//

#import "ODSSaveBackAPI.h"

/**
 * The Alfresco private metadata will be stored in the annotation dictionary under this key. It should be returned in the
 * same format, using the same key, when invoking a Save Back operation.
 */
NSString * const ODSSaveBackMetadataKey = @"ODSMetadata";

/**
 * Limit the "Open In..." list of available apps, part 1:
 * The document must be renamed so that the following extension is appended to the filename. For example "My Document.docx.alfrescosaveback"
 */
NSString * const ODSSaveBackDocumentExtension = @".odssaveback";

/**
 * Limit the "Open In..." list of available apps, part 2:
 * The UIDocumentInteractionController's UTI property must be set to a unique string.
 */
NSString * const ODSSaveBackUTI = @"com.ods.mobile.saveback";


/**
 * Save Back to Alfresco helper function.
 *
 * The function is given the path to a document and will return a URL representing a suitably renamed document
 * ready to participate in the Save Back operation. The renamed document will be created in the temporary directory.
 */
NSURL *odsSaveBackURLForFilePath(NSString *filePath, NSError **error)
{
    NSString *tempFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:filePath.pathComponents.lastObject];
    NSString *tempSaveBackPath = [tempFilename stringByAppendingString:ODSSaveBackDocumentExtension];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tempSaveBackPath])
    {
        if ([fileManager removeItemAtPath:tempSaveBackPath error:error] == NO)
        {
            return nil;
        }
    }
    
    if ([fileManager copyItemAtPath:filePath toPath:tempSaveBackPath error:error] == NO)
    {
        return nil;
    }
    
    return [NSURL fileURLWithPath:tempSaveBackPath];
}
