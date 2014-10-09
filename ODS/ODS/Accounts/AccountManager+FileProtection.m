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
//  AccountManager+FileProtection.m
//

#import "AccountManager+FileProtection.h"

static NSString * const isQualifyngAccountPredicateFormat = @"isQualifyingAccount == %@";

@implementation AccountManager (FileProtection)
- (BOOL)addAsQualifyingAccount:(NSString *)accountUUID
{
    AccountInfo *accountInfo = [self accountInfoForUUID:accountUUID];
    [accountInfo setIsQualifyingAccount:YES];
    
    if([accountInfo isQualifyingAccount])
    {
        [self saveAccountInfo:accountInfo withNotification:NO];
        return YES;
    } else
    {
        return NO;
    }
}

- (void)removeAsQualifyingAccount:(NSString *)accountUUID
{
    AccountInfo *accountInfo = [self accountInfoForUUID:accountUUID];
    [accountInfo setIsQualifyingAccount:NO];
    [self saveAccountInfo:accountInfo withNotification:NO];
}

- (BOOL)hasQualifyingAccount
{
    return [self numberOfQualifyingAccounts] > 0;
}

- (NSInteger)numberOfQualifyingAccounts
{
    NSPredicate *isQualifyingPredicate = [NSPredicate predicateWithFormat:isQualifyngAccountPredicateFormat, [NSNumber numberWithBool:YES]];
    NSArray *array = [self allAccounts];
    array = [array filteredArrayUsingPredicate:isQualifyingPredicate];
    
    return [array count];
}
@end
