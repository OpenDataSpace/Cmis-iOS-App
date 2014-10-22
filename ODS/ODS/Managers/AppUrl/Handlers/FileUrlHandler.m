//
//  FileUrlHandler.m
//  ODS
//
//  Created by bdt on 10/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "FileUrlHandler.h"
#import "FileUtils.h"
#import "AppDelegate.h"
#import "DocumentViewController.h"
#import "NSNotificationCenter+CustomNotification.h"
#import "SaveBackMetadata.h"

NSString * const LegacyFileMetadataKey = @"PartnerApplicationFileMetadataKey";
NSString * const LegacyDocumentPathKey = @"PartnerApplicationDocumentPath";

@interface FileUrlHandler ()
@property (nonatomic, retain) SaveBackMetadata *saveBackMetadata;
@end

@implementation FileUrlHandler
@synthesize saveBackMetadata = _saveBackMetadata;

#pragma mark -
#pragma mark App URL Handler Delegate
- (NSString *)handledUrlPrefix:(NSString *)defaultAppScheme {
    return @"file://";
}

- (void)handleUrl:(NSURL *)url annotation:(id)annotation {
    // Common Save Back parameters
    SaveBackMetadata *saveBackMetadata = nil;
    
    ODSLogDebug(@"Handle File URL:%@", url);
    
    NSString *receivedSecretUUID = [annotation objectForKey:QuickofficeApplicationSecretUUIDKey];
    if ([receivedSecretUUID isEqualToString:externalAPIKey(APIKeyQuickoffice)])
    {
        NSDictionary *partnerInfo = [annotation objectForKey:QuickofficeApplicationInfoKey];
        
        // Check for legacy data, pre-1.4
        // This possibility might arise if the Alfresco app is upgraded whilst documents are still being edited
        // in Quickoffice.
        NSDictionary *legacyMetadata = [partnerInfo objectForKey:LegacyFileMetadataKey];
        if (legacyMetadata != nil)
        {
            DownloadMetadata *downloadMeta = [[DownloadMetadata alloc] initWithDownloadInfo:legacyMetadata];
            saveBackMetadata = [[SaveBackMetadata  alloc] init];
            saveBackMetadata.accountUUID = downloadMeta.accountUUID;
            saveBackMetadata.objectId = downloadMeta.objectId;
            saveBackMetadata.originalPath = [partnerInfo objectForKey:LegacyDocumentPathKey];
        }
        else
        {
            saveBackMetadata = [[SaveBackMetadata alloc] initWithDictionary:partnerInfo];
        }
    }
    else
    {
        // Check annotation data for ODS generic "Save Back" integration
        NSDictionary *odsMetadata = [annotation objectForKey:ODSSaveBackMetadataKey];
        if (odsMetadata != nil)
        {
            saveBackMetadata = [[SaveBackMetadata alloc] initWithDictionary:odsMetadata];
        }
    }
    
    NSURL *saveToURL = nil;
    [self setSaveBackMetadata:saveBackMetadata];
    
    // Found Save Back metadata?
    if (saveBackMetadata != nil)
    {
        // Save the file back where it came from (or to a temp folder)
        saveToURL = [self saveIncomingFileWithURL:url toFilePath:saveBackMetadata.originalPath withFileName:saveBackMetadata.originalName];
        
        if (saveToURL != nil)
        {
            // display the contents of the saved file
            [self displayDownloadedFileWithURL:saveToURL];
        }
    }
    else
    {
        // Save the incoming file
        saveToURL = [self saveIncomingFileWithURL:url];
        
        // Set the "do not backup" flag
        addSkipBackupAttributeToItemAtURL(saveToURL);
        
        if (saveToURL != nil)
        {
            // display the contents of the saved file
            [self displayDownloadedFileWithURL:saveToURL];
        }
    }
    
   
}

#pragma mark - Private methods
- (NSURL *)saveIncomingFileWithURL:(NSURL *)url
{
    return [self saveIncomingFileWithURL:url toFilePath:nil withFileName:nil];
}

- (NSURL *)saveIncomingFileWithURL:(NSURL *)url toFilePath:(NSString *)filePath withFileName:fileName
{
    NSString *incomingFilePath = [url path];
    NSString *incomingFileName = fileName != nil ? fileName : [[incomingFilePath pathComponents] lastObject];
    NSString *saveToPath = filePath != nil ? filePath : [FileUtils pathToSavedFile:incomingFileName];
    NSURL *saveToURL = [NSURL fileURLWithPath:saveToPath];
    
    if ([saveToURL isEqual:url])
    {
        return saveToURL;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:saveToPath])
    {
        [fileManager removeItemAtPath:saveToPath error:&error];
    }
    
    BOOL incomingFileMovedSuccessfully = [fileManager moveItemAtPath:[url path] toPath:saveToPath error:&error];
    return incomingFileMovedSuccessfully ? saveToURL : nil;
}

- (void)displayDownloadedFileWithURL:(NSURL *)url {
    NSString *incomingFilePath = [url path];
    NSString *filename = [[incomingFilePath pathComponents] lastObject];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *mainStoryboard = instanceMainStoryboard();
    DocumentViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DocumentControllerIdentifier"];
    [viewController setIsDownloaded:YES];
    
    UINavigationController *downloadsNavController = appDelegate.downloadNavController;
    [downloadsNavController popToRootViewControllerAnimated:NO];
    [appDelegate.tabBarController setSelectedViewController:downloadsNavController];
    
    if (IS_IPAD)
    {
        [IpadSupport clearDetailController];
        [IpadSupport showMasterPopover];
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:incomingFilePath];
    [viewController setFileName:filename];
    [viewController setFileData:fileData];
    [viewController setFilePath:incomingFilePath];
    [viewController setHidesBottomBarWhenPushed:YES];
    
    if (IS_IPAD)
    {
        [IpadSupport pushDetailController:viewController withNavigation:downloadsNavController andSender:self];
    }
    else
    {
        [downloadsNavController pushViewController:viewController animated:NO];
    }
    
    // Updated document parameters notification
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"objectId",
                              [url path], @"newPath", nil];
    [[NSNotificationCenter defaultCenter] postDocumentUpdatedNotificationWithUserInfo:userInfo];
}

@end
