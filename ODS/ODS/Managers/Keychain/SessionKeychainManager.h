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
//  SessionKeychainManager.h
//
// The SessionKeychainManager provides methods to access and to store information into the App Session 
// All the information is stored in the keychain.

#import <Foundation/Foundation.h>
@class DataKeychainItemWrapper;

@interface SessionKeychainManager : NSObject
@property (nonatomic, retain) DataKeychainItemWrapper *keychain; //Keychain wrapper that writes to the keychain

/*
 Creates a new SessionKeychainManager object with a given keychain.
 */
- (id)initWithKeychain:(DataKeychainItemWrapper *)keychain;

/*
 Returns the password for an accountUUID if it is in the session
 */
- (NSString *)passwordForAccountUUID:(NSString *)accountUUID;
/*
 Saves a password in the session for a given accountUUID.
 */
- (void)savePassword:(NSString *)password forAccountUUID:(NSString *)accountUUID;
/*
 Removes a password in the session for a given accountUUID.
 */
- (void)removePasswordForAccountUUID:(NSString *)accountUUID;

/*
 Clears the current session managed by the instance
 */
- (void)clearSession;

/*
 Returns a default instance of the SessionKeychainManager. The keychain identifier used is a constant for the user
 application session.
 */
+ (SessionKeychainManager *)sharedManager;
@end
