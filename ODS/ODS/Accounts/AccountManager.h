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
//  AccountMananger.h
//


#import <Foundation/Foundation.h>
#import "AccountInfo.h"

@interface AccountManager : NSObject
{
}


- (NSArray *)allAccounts;
/*
 Returns all the accounts that are acive. Determined by the property accountStatus (value:FDAccountStatusActive) 
 in the accounInfo object.
 */
- (NSArray *)activeAccounts;
- (NSArray *)inactiveAccounts;
/*
 Returns all the accounts that are awaiting verification. Determined by the property accountStatus (value:FDAccountStatusAwaitingVerification) 
 in the accounInfo object.
 */
- (NSArray *)awaitingVerificationAccounts;
- (NSArray *)errorAccounts;
- (NSArray *)noPasswordAccounts;
- (NSArray *)passwordAccounts;
- (NSArray *)activeAccountsWithPassword;
- (BOOL)saveAccounts:(NSArray *)accountArray;
//

- (BOOL)isAccountActive:(NSString *)uuid;

// If an AccountInfo object with the same UUID exists, the existing object will
// be replaced with the incoming object in the message
- (BOOL)saveAccountInfo:(AccountInfo *)accountInfo;
- (BOOL)saveAccountInfo:(AccountInfo *)accountInfo withNotification:(BOOL)notification;
- (BOOL)saveAccountInfo:(AccountInfo *)accountInfo withNotification:(BOOL)notification synchronize:(BOOL)synchronize;
/*
 The accountInfo that matches the UUID provided will be removed from the list of accounts
 */
- (BOOL)removeAccountInfo:(AccountInfo *)accountInfo;
- (AccountInfo *)accountInfoForUUID:(NSString *)uuid;

/*
 Provides the first active AccountInfo object with the same hostname, returns nil if no match found
 */
- (AccountInfo *)accountInfoForHostname:(NSString *)hostname;
/**
 * As above, but optionally includes inactive accounts
 */
- (AccountInfo *)accountInfoForHostname:(NSString *)hostname includeInactiveAccounts:(BOOL)includeInactive;
/**
 * As above, with the ability to specify a username (used by documentPreviewUrl handler)
 */
- (AccountInfo *)accountInfoForHostname:(NSString *)hostname username:(NSString *)username includeInactiveAccounts:(BOOL)includeInactive;

+ (id)sharedManager;

@end
