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
//  AccountStatusService.m
//

#import "AccountStatusService.h"
#import "FileUtils.h"
#import "AccountStatus.h"
NSString * const kAccountStatusStoreFilename = @"AccountStatusDataStore.plist";

@implementation AccountStatusService

- (void)dealloc
{
    _accountStatusCache = nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _accountStatusCache = [NSKeyedUnarchiver unarchiveObjectWithFile:[FileUtils pathToConfigFile:kAccountStatusStoreFilename]];
        if (!_accountStatusCache)
        {
            _accountStatusCache = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (AccountStatus *)accountStatusForUUID:(NSString *)uuid
{
    return [_accountStatusCache objectForKey:uuid];
}

- (void)saveAccountStatus:(AccountStatus *)accountStatus
{
    [_accountStatusCache setObject:accountStatus forKey:[accountStatus uuid]];
    [self synchronize];
}

- (void)removeAccountStatusForUUID:(NSString *)uuid
{
    [_accountStatusCache removeObjectForKey:uuid];
    [self synchronize];
}

- (void)synchronize
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_accountStatusCache];
    NSError *error = nil;
    NSString *path = [FileUtils pathToConfigFile:kAccountStatusStoreFilename];
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
}

#pragma mark - Singleton

+ (AccountStatusService *)sharedService
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

@end
