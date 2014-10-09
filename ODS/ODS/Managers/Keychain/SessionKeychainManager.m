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
//  SessionKeychainManager.m
//

#import "SessionKeychainManager.h"
#import "DataKeychainItemWrapper.h"
#import "AccountManager.h"
#import "NSNotificationCenter+CustomNotification.h"

NSString * const kKeychainAppSession_Identifier = @"AppSession";

@implementation SessionKeychainManager
@synthesize keychain = _keychain;

- (void)dealloc
{
    [_keychain release];
    [super dealloc];
}

- (id)initWithKeychain:(DataKeychainItemWrapper *)keychain
{
    self = [super init];
    if(self)
    {
        [self setKeychain:keychain];
    }
    return self;
}

- (NSMutableDictionary *)appSession
{
    NSData *serializedAccountListData = [self.keychain objectForKey:(id)kSecValueData];
    if (serializedAccountListData && serializedAccountListData.length > 0)
    {
        NSMutableDictionary *deserializedSession = [NSKeyedUnarchiver unarchiveObjectWithData:serializedAccountListData];
        if (deserializedSession)
        {
            return deserializedSession;
        }
    }
    
    return [NSMutableDictionary dictionary];
}

- (void)saveAppSession:(NSMutableDictionary *)appSession
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:appSession];
    [self.keychain setObject:data forKey:(id)kSecValueData];
}

- (NSString *)passwordForAccountUUID:(NSString *)accountUUID
{
    NSMutableDictionary *appSession = [self appSession];
    NSMutableDictionary *passwords = [appSession objectForKey:@"passwords"];
    
    return [passwords objectForKey:accountUUID];
}

- (void)savePassword:(NSString *)password forAccountUUID:(NSString *)accountUUID
{
    NSMutableDictionary *appSession = [self appSession];
    NSMutableDictionary *passwords = [appSession objectForKey:@"passwords"];
    
    if(!passwords)
    {
        passwords = [NSMutableDictionary dictionary];
        [appSession setObject:passwords forKey:@"passwords"];
    }
    
    [passwords setObject:password forKey:accountUUID];
    [self saveAppSession:appSession];
}

- (void)removePasswordForAccountUUID:(NSString *)accountUUID
{
    NSMutableDictionary *appSession = [self appSession];
    NSMutableDictionary *passwords = [appSession objectForKey:@"passwords"];
    [passwords removeObjectForKey:accountUUID];
    [self saveAppSession:appSession];
}

- (void)clearSession
{
    static NSString *KeyPath = @"tenantID";
    [self.keychain resetKeychainItem];
    
    // We also need to clear any cached request
    NSArray *accounts = [[AccountManager sharedManager] noPasswordAccounts];
    /*RepositoryServices *repoService = [RepositoryServices shared];
    for (AccountInfo *account in accounts)
    {
        NSArray *repos = [repoService getRepositoryInfoArrayForAccountUUID:account.uuid];
        NSArray *tenantIDs = [repos valueForKeyPath:KeyPath];
        // For cloud accounts, there is one instance for each tenant the cloud account contains
        for (NSString *anID in tenantIDs) 
        {
            [[SitesManagerService sharedInstanceForAccountUUID:account.uuid tenantID:anID] invalidateResults];
        }
        [repoService invalidateRepositoriesForAccountUuid:account.uuid];
        [[NSNotificationCenter defaultCenter] postSessionClearedNotificationWithUserInfo:@{@"accountUUID": account.uuid}];
    }*/
}

#pragma mark - Shared Instance

static SessionKeychainManager *sharedKeychainMananger = nil;

+ (SessionKeychainManager *)sharedManager
{
    if (sharedKeychainMananger == nil)
    {
        DataKeychainItemWrapper *keychain = [[[DataKeychainItemWrapper alloc] initWithIdentifier:kKeychainAppSession_Identifier accessGroup:nil] autorelease];
        [keychain setObject:@"SessionService" forKey:(id)kSecAttrService];
        sharedKeychainMananger = [[super alloc] initWithKeychain:keychain];
    }
    return sharedKeychainMananger;
}


@end
