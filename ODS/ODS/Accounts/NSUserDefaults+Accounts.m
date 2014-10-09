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
//  NSUserDefaults+Accounts.m
//  

#import "NSUserDefaults+Accounts.h"

NSString * const kAccountList_Identifier = @"AccountList";

@implementation NSUserDefaults (Accounts)

- (NSArray *)accountList
{
    NSData *serializedAccountListData = [self objectForKey:kAccountList_Identifier];
    if (serializedAccountListData && serializedAccountListData.length > 0)
    {
        NSArray *deserializedArray = [NSKeyedUnarchiver unarchiveObjectWithData:serializedAccountListData];
        if (deserializedArray)
        {
            return deserializedArray;
        }
    }
    
    return [NSArray array];
}

//
// return YES if the data was saved successfully to disk, otherwise NO.
//
- (BOOL)saveAccountList:(NSArray *)list2Save
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list2Save];
    [self setObject:data forKey:kAccountList_Identifier];
    return [self synchronize];
}

- (BOOL)removeAccounts
{
    [self removeObjectForKey:kAccountList_Identifier];
    return [self synchronize];
}

@end
