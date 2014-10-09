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
//  NSNotificationCenter+CustomNotification.h
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (CustomNotification)
/*
 * Used to post notification about account changes.
 * User Info:
 *    (NSString *) "type": can be @"add", @"delete" or @"edit"
 *    (NSNumber *) "reset": Indicates if the account change is from a app reset
 *    (NSString *) "uuid": The UUID of the account added, deleted or edited
 */
- (void)postAccountListUpdatedNotification:(NSDictionary *)userInfo;

/*
 * Used to post notification about account status changes.
 * User Info:
 *    (AccountStatus *) "accountStatus": AccountStatus object that changed
 */
- (void)postAccountStatusChangedNotification:(NSDictionary *)userInfo;

/*
 * When the user taps the "Browse Documents" in an account detail this notification should be posted
 * User Info:
 *    (NSString *) "accountUUID": The UUID of the account to browse
 */
- (void)postBrowseDocumentsNotification:(NSDictionary *)userInfo;

/*
 * Used to post notification when the detailViewController Changed.
 * Only for iPad and it's used to deselect if a cell is selected indicating that is displaying
 * in the detailView
 *
 * User Info:
 *    (DownloadMetadata *) "fileMetadata": The download metadata related to the cell. When applicable, to better identify the
 *                       selected cell if the original list is updated
 */
- (void)postDetailViewControllerChangedNotificationWithSender:(id)sender userInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a user preference that affects the information displayed in a screen.
 *
 * User Info: None
 */
- (void)postUserPreferencesChangedNotification;

/*
 * Sync preference has been changed
 *
 * User Info: None
 */
- (void)postSyncPreferenceChangedNotification:(id)sender;


/*
 * Notifcation that the last sync operation encountered obstacles (conflicts)
 *
 * User Info:
 *    (NSDictionary *) "syncObstacles": NSDictionary containing:
 *        (NSArray *) kDocumentsUnfavoritedOnServerWithLocalChanges: Array of unfavorited files which are modified locally
 *        (NSArray *) kDocumentsDeletedOnServerWithLocalChanges: Array of deleted synced files which are modified locally
 */
- (void)postSyncObstaclesNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a user default in the keychain changed (after calling the synchronize method)
 *
 * User Info: None
 */
- (void)postKeychainUserDefaultsDidChangeNotification;


- (void)postLastAccountDetailsNotification:(NSDictionary *)userInfo;

/*
 * MDM Lite: Expired files notification
 *
 * User Info:
 *    (NSArray *) "expiredDownloadFiles": Array of downloaded files which have passed expiry time
 *    (NSArray *) "expiredSyncFiles": Array of sync'ed files which have passed expiry time
 */
- (void)postExpiredFilesNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * MDM Lite: Expired file update notification (specifically for document currently being viewed)
 *
 * User Info:
 *    (NSNumber *) "restrictionStatus" : Boolean value indicating current restriction status
 */
- (void)postViewedDocumentRestrictionStatusNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when an upload finished successfully
 *
 * User Info:
 *    (NSString *) "uploadUUID": The UUID of the Upload that finished successfully
 *    (UploadInfo *) "uploadInfo": The upload metadata of the success upload
 */
- (void)postUploadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a upload request failed 
 *
 * User Info:
 *    (NSString *) "uploadUUID": The UUID of the Upload that failed
 *    (UploadInfo *) "uploadInfo": The upload metadata of the failed upload
 */
- (void)postUploadFailedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when an upload is added, deleted, finished or failed.
 *
 * User Info:
 *    (NSString *) "uploadUUID": The UUID of the Upload that failed
 *    (UploadInfo *) "uploadInfo": The upload metadata of the failed upload
 */
- (void)postUploadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when an upload started the upload, it means we
 * can now start tracking its upload progress
 *
 * User Info:
 *    (NSString *) "uploadUUID": The UUID of the Upload that failed
 *    (UploadInfo *) "uploadInfo": The upload metadata of the starting upload
 */
- (void)postUploadStartedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when an upload is waiting for upload.
 * The more common case is when we retry an upload
 *
 * User Info:
 *    (NSString *) "uploadUUID": The UUID of the Upload that failed
 *    (UploadInfo *) "uploadInfo": The upload metadata of the waiting upload
 */
- (void)postUploadWaitingNotificationWithUserInfo:(NSDictionary *)userInfo;


- (void)postFavoriteUploadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)postFavoriteUploadFailedNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)postFavoriteUploadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)postFavoriteUploadStartedNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)postFavoriteUploadWaitingNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)postFavoriteUploadCancelledNotificationWithUserInfo:(NSDictionary *)userInfo;
/*
 * Used to post notification when a download finished successfully
 *
 * User Info:
 *    (NSString *) "downloadObjectId": The CMIS Object Id of the download that finished successfully
 *    (DownloadInfo *) "downloadInfo": The download metadata of the success download
 */
- (void)postDownloadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a upload request failed 
 *
 * User Info:
 *    (NSString *) "downloadObjectId": The CMIS Object Id of the download that finished successfully
 *    (DownloadInfo *) "downloadInfo": The download metadata of the success download
 */
- (void)postDownloadFailedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when an upload is added, deleted, finished or failed.
 *
 * User Info:
 *    (NSString *) "downloadObjectId": The CMIS Object Id of the download that finished successfully
 *    (DownloadInfo *) "downloadInfo": The download metadata of the success download
 */
- (void)postDownloadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo;

- (void)postDownloadStartedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a document was updated in the repository.
 *
 * User Info:
 *    (NSString *) "objectId": The CMIS Object Id of the updated document
 *    (RepositoryItem *) "repositoryItem": The latest version of the Repository item  
 */
- (void)postDocumentUpdatedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a favorite download finished successfully
 *
 * User Info:
 *    (NSString *) "downloadObjectId": The CMIS Object Id of the download that finished successfully
 *    (DownloadInfo *) "downloadInfo": The download metadata of the success download
 */
- (void)postFavoriteDownloadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when a favorite download request failed 
 *
 * User Info:
 *    (NSString *) "downloadObjectId": The CMIS Object Id of the download that finished successfully
 *    (DownloadInfo *) "downloadInfo": The download metadata of the success download
 */
- (void)postFavoriteDownloadFailedNotificationWithUserInfo:(NSDictionary *)userInfo;

/*
 * Used to post notification when an favorite download is added, deleted, finished or failed.
 *
 * User Info:
 *    (NSString *) "downloadObjectId": The CMIS Object Id of the download that finished successfully
 *    (DownloadInfo *) "downloadInfo": The download metadata of the success download
 */
- (void)postFavoriteDownloadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo;

- (void)postFavoriteDownloadStartedNotificationWithUserInfo:(NSDictionary *)userInfo;

- (void)postFavoriteDownloadCancelledNotificationWithUserInfo:(NSDictionary *)userInfo;

- (void)postDocumentFavoritedOrUnfavoritedNotificationWithUserInfo:(NSDictionary *)userInfo;

/**
 * Used to post a notification when a task has been completed.
 *
 * User Info:
 *      (NSString *) "taskId" : the id of the task which has been completed.
 */
- (void)postTaskCompletedNotificationWithUserInfo:(NSDictionary *)userInfo;

/**
 * Used to post a notification when a account's session has been cleared, either by timing out, or by the app being backgrounded
 *
 * User Info:
 *    (NSString *) "accountUUID": The UUID of the account that has been cleared
 */
- (void)postSessionClearedNotificationWithUserInfo:(NSDictionary *)userInfo;

@end
