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
//  AccountKeychainManager.m
//

#import "AccountKeychainManager.h"
#import "DataKeychainItemWrapper.h"
#import "AccountInfo.h"

NSString * const kKeychainAccountList_Identifier = @"AccountList";
NSString * const kServiceName = @"cc.dataspace.ODService";

@implementation AccountKeychainManager
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

- (NSMutableArray *)accountList
{
    NSData *serializedAccountListData = [self.keychain objectForKey:(id)kSecValueData];
    if (serializedAccountListData && serializedAccountListData.length > 0)
    {
        NSMutableArray *deserializedArray = [NSKeyedUnarchiver unarchiveObjectWithData:serializedAccountListData];
        if (deserializedArray)
        {
            return deserializedArray;
        }
    }
    
    return [NSMutableArray array];
}

//
// return YES if the data was saved successfully to disk, otherwise NO.
//
- (BOOL)saveAccountList:(NSMutableArray *)list2Save
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list2Save];
    [self.keychain setObject:data forKey:(id)kSecValueData];
    return YES;
}

#pragma mark - Shared Instance

static AccountKeychainManager *sharedKeychainMananger = nil;

+ (AccountKeychainManager *)sharedManager
{
    if (sharedKeychainMananger == nil) {
        DataKeychainItemWrapper *keychain = [[[DataKeychainItemWrapper alloc] initWithIdentifier:kKeychainAccountList_Identifier accessGroup:nil] autorelease];
        
        sharedKeychainMananger = [[super alloc] initWithKeychain:keychain];
    }
    return sharedKeychainMananger;
}

@end
