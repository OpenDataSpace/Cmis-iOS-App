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
//  AccountStatusService.h
//
// The AccountStatusService manages the AccountStatus objects persistence into a data store.
// The current implementation uses a plist with a dictionary as the root, the key used is 
// the accountUUID and the value is the AccountStatus object encoded with the NSKeyedArchiver.
// The AccountStatusService uses a NSMutableDictionary cache, all of the managed AccountStatus
// objects should be contained in that Dictionary for convenience so we can easily change the
// accountStatusInfo property in any AccountInfo object and know that it's managed by this class.
// Changes in an AccountStatus objects will not be synchronized to the data store, a call to the
// synchronize method should be made in order to persist any account status changes.
//
// The cache is initialized from the datastore and does not read into the datastore after that.

#import <Foundation/Foundation.h>
@class AccountStatus;

@interface AccountStatusService : NSObject
{
    @private
    NSMutableDictionary *_accountStatusCache;
}

/*
 Retrieves the AccountStatus object cached in the accountStatusCache
 */
- (AccountStatus *)accountStatusForUUID:(NSString *)uuid;
/*
 Saves an account status into the cache after saving it, the account status cache is
 persisted to the datastore
 */
- (void)saveAccountStatus:(AccountStatus *)accountStatus;
/*
 Removes an account status from the cache after removing it, the account status cache is
 persisted to the datastore
 */
- (void)removeAccountStatusForUUID:(NSString *)uuid;
/*
 Persistes the current account status cache into the datastore
 */
- (void)synchronize;

/*
 Shared service instance for the AccountStatusService class
 */
+ (AccountStatusService *)sharedService;
@end
