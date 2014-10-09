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
//  NSNotificationCenter+CustomNotification.m
//

#import "NSNotificationCenter+CustomNotification.h"

@implementation NSNotificationCenter (CustomNotification)

- (void)postAccountListUpdatedNotification:(NSDictionary *)userInfo 
{
    [self postNotificationName:kNotificationAccountListUpdated object:nil userInfo:userInfo];
}

- (void)postAccountStatusChangedNotification:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationAccountStatusChanged object:nil userInfo:userInfo];
}

- (void)postBrowseDocumentsNotification:(NSDictionary *)userInfo 
{
    [self postNotificationName:kBrowseDocumentsNotification object:nil userInfo:userInfo];
}

- (void)postDetailViewControllerChangedNotificationWithSender:(id)sender userInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kDetailViewControllerChangedNotification object:sender userInfo:userInfo];
}

- (void)postUserPreferencesChangedNotification 
{
    [self postNotificationName:kUserPreferencesChangedNotification object:nil userInfo:nil];
}

- (void)postSyncPreferenceChangedNotification:(id)sender
{
    [self postNotificationName:kSyncPreferenceChangedNotification object:sender userInfo:nil];
}

//- (void)postSyncObstaclesNotificationWithUserInfo:(NSDictionary *)userInfo
//{
//    [self postNotificationName:kNotificationSyncObstacles object:nil userInfo:userInfo];
//}

- (void)postKeychainUserDefaultsDidChangeNotification 
{
    [self postNotificationName:kKeychainUserDefaultsDidChangeNotification object:nil userInfo:nil];
}

- (void)postLastAccountDetailsNotification:(NSDictionary *)userInfo 
{
    [self postNotificationName:kLastAccountDetailsNotification object:nil userInfo:userInfo];
}

- (void)postUploadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationUploadFinished object:nil userInfo:userInfo];
}

- (void)postUploadFailedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationUploadFailed object:nil userInfo:userInfo];
}

- (void)postUploadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationUploadQueueChanged object:nil userInfo:userInfo];
}

- (void)postUploadStartedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationUploadStarted object:nil userInfo:userInfo];
}

- (void)postUploadWaitingNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationUploadWaiting object:nil userInfo:userInfo];
}

- (void)postFavoriteUploadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteUploadFinished object:nil userInfo:userInfo];
}

- (void)postFavoriteUploadFailedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteUploadFailed object:nil userInfo:userInfo];
}

- (void)postFavoriteUploadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteUploadQueueChanged object:nil userInfo:userInfo];
}

- (void)postFavoriteUploadStartedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteUploadStarted object:nil userInfo:userInfo];
}

- (void)postFavoriteUploadWaitingNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteUploadWaiting object:nil userInfo:userInfo];
}

- (void)postFavoriteUploadCancelledNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteUploadCancelled object:nil userInfo:userInfo];
}

- (void)postDownloadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationDownloadFinished object:nil userInfo:userInfo];
}

- (void)postDownloadFailedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationDownloadFailed object:nil userInfo:userInfo];
}

- (void)postDownloadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationDownloadQueueChanged object:nil userInfo:userInfo];
}

- (void)postDownloadStartedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationDownloadStarted object:nil userInfo:userInfo];
}

- (void)postDocumentUpdatedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationDocumentUpdated object:nil userInfo:userInfo];
}
- (void)postFavoriteDownloadFinishedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteDownloadFinished object:nil userInfo:userInfo];
}

- (void)postFavoriteDownloadFailedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteDownloadFailed object:nil userInfo:userInfo];
}

- (void)postFavoriteDownloadQueueChangedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteDownloadQueueChanged object:nil userInfo:userInfo];
}

- (void)postFavoriteDownloadStartedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteDownloadStarted object:nil userInfo:userInfo];
}

- (void)postFavoriteDownloadCancelledNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationFavoriteDownloadCancelled object:nil userInfo:userInfo];
}

//- (void)postDocumentFavoritedOrUnfavoritedNotificationWithUserInfo:(NSDictionary *)userInfo
//{
//    [self postNotificationName:kNotificationDocumentFavoritedOrUnfavorited object:nil userInfo:userInfo];
//}
- (void)postTaskCompletedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationTaskCompleted object:nil userInfo:userInfo];
}

//- (void)postExpiredFilesNotificationWithUserInfo:(NSDictionary *)userInfo
//{
//    [self postNotificationName:kNotificationExpiredFiles object:nil userInfo:userInfo];
//}
//
//- (void)postViewedDocumentRestrictionStatusNotificationWithUserInfo:(NSDictionary *)userInfo
//{
//    [self postNotificationName:kNotificationViewedDocumentRestrictionStatus object:nil userInfo:userInfo];
//}

- (void)postSessionClearedNotificationWithUserInfo:(NSDictionary *)userInfo
{
    [self postNotificationName:kNotificationSessionCleared object:nil userInfo:userInfo];
}

@end
