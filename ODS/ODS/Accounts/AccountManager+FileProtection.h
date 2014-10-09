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
//  AccountManager+FileProtection.h
//
// Adds File protection related utiliy methods to the AccountManager class.
// 

#import "AccountManager.h"

@interface AccountManager (FileProtection)
/*
 It sets to YES the isQualifyingAccount flag in the accountInfo object for the uuid
 It returns YES if we successfully added the account and NO if the account was excluded and
 couldn't add as a qualifying account.
 */
- (BOOL)addAsQualifyingAccount:(NSString *)accountUUID;
/*
 It sets to NO the isQualifyingAccount flag in the accountInfo object for the uuid
 */
- (void)removeAsQualifyingAccount:(NSString *)accountUUID;
/*
 Searches the list of accounts for a qualifying account for data protection.
 */
- (BOOL)hasQualifyingAccount;
/*
 Searches the list of accounts and returns the number of qualifying accounts.
 */
- (NSInteger)numberOfQualifyingAccounts;
@end
