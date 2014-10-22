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
//  PreviewManager.h
//

#import <Foundation/Foundation.h>
#import "CMISDownloadFileRequest.h"

@class PreviewManager;
@class DownloadInfo;

@protocol PreviewManagerDelegate <NSObject>
@optional
- (void)previewManager:(PreviewManager *)manager downloadCancelled:(DownloadInfo *)info;
- (void)previewManager:(PreviewManager *)manager downloadStarted:(DownloadInfo *)info;
- (void)previewManager:(PreviewManager *)manager downloadFinished:(DownloadInfo *)info;
- (void)previewManager:(PreviewManager *)manager downloadFailed:(DownloadInfo *)info withError:(NSError *)error;

@end

@interface PreviewManager : NSObject {
}

@property (nonatomic, strong, readonly) DownloadInfo *currentDownload;
@property (nonatomic, assign) id<PreviewManagerDelegate> delegate;
@property (nonatomic, assign) id progressIndicator;

+ (PreviewManager *)sharedManager;

// Queue an item for preview
- (void)previewItem:(CMISObject *)item delegate:(id<PreviewManagerDelegate>)aDelegate accountUUID:(NSString *)anAccountUUID repositoryID:(NSString*)aRepositoryID tenantID:(NSString *)aTenantID;

// Cancel current preview request
- (void)cancelPreview;

// Reconnect delegate. Sends another downloadStarted message
- (void)reconnectWithDelegate:(id<PreviewManagerDelegate>)aDelegate;

// Is the CMIS Object current being downloaded for preview?
- (BOOL)isManagedPreview:(NSString *)cmisObjectId;

// Receives download progress information from downloads being handled by the DownloadManager
- (void)downloadProgress:(float)newProgress forDownloadInfo:(DownloadInfo *)downloadInfo;

// Current progress value, if available. Returns 0 if not known
- (float)currentProgress;

@end
