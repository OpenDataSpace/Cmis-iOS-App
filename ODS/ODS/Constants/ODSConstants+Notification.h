/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
//
//  ODSConstants+Notification.h
//  ODS
//
//  Created by bdt on 8/6/14.
//  Copyright (c) 2014 OpenDataSpace. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// General Notification Types
//
extern NSString * const kDetailViewControllerChangedNotification;
extern NSString * const kUserPreferencesChangedNotification;
extern NSString * const kKeychainUserDefaultsDidChangeNotification;

extern NSString * const kSyncPreferenceChangedNotification;
//
// Repo/AccountList Notification Types
//
extern NSString * const kNotificationAccountListUpdated;
extern NSString * const kNotificationAccountStatusChanged;

//
// Uploads Notification Types
//
extern NSString * const kNotificationUploadFinished;
extern NSString * const kNotificationUploadFailed;
extern NSString * const kNotificationUploadQueueChanged;
extern NSString * const kNotificationUploadStarted;
extern NSString * const kNotificationUploadWaiting;
extern NSString * const kNotificationFavoriteUploadCancelled;

//
// Favorite Uploads Notification Types
//
extern NSString * const kNotificationFavoriteUploadFinished;
extern NSString * const kNotificationFavoriteUploadFailed;
extern NSString * const kNotificationFavoriteUploadQueueChanged;
extern NSString * const kNotificationFavoriteUploadStarted;
extern NSString * const kNotificationFavoriteUploadWaiting;

//
// Downloads Notification Types
//
extern NSString * const kNotificationDownloadFinished;
extern NSString * const kNotificationDownloadFailed;
extern NSString * const kNotificationDownloadQueueChanged;
extern NSString * const kNotificationDownloadStarted;

//
// Repository Documents Notification Types
//
extern NSString * const kNotificationDocumentUpdated;

//
// Favorite Downloads Notification Types
//
extern NSString * const kNotificationFavoriteDownloadFinished;
extern NSString * const kNotificationFavoriteDownloadFailed;
extern NSString * const kNotificationFavoriteDownloadQueueChanged;
extern NSString * const kNotificationFavoriteDownloadStarted;
extern NSString * const kNotificationFavoriteDownloadCancelled;

//
// Account Notification Types
//
extern NSString * const kAccountUpdateNotificationEdit;
extern NSString * const kAccountUpdateNotificationDelete;
extern NSString * const kAccountUpdateNotificationAdd;
extern NSString * const kAccountUpdateNotificationAllAccounts;
extern NSString * const kBrowseDocumentsNotification;
extern NSString * const kLastAccountDetailsNotification;
extern NSString * const kNotificationSessionCleared;

//
// Task notification types
//
extern NSString * const kNotificationTaskCompleted;


@interface ODSConstants_Notification : NSObject

@end
