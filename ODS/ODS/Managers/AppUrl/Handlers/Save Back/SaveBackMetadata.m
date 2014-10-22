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
// SaveBackMetadata.m
//
#import "SaveBackMetadata.h"

@implementation SaveBackMetadata
@synthesize accountUUID = _accountUUID;
@synthesize objectId = _objectId;
@synthesize originalPath = _originalPath;
@synthesize originalName = _originalName;

- (void)dealloc
{
    _accountUUID = nil;
    _objectId = nil;
    _originalPath = nil;
    _originalName = nil;

}

- (id)initWithDictionary:(NSDictionary *)metadata
{
    self = [super init];
    if (self && metadata != nil)
    {
        [self setValuesForKeysWithDictionary:metadata];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[self allKeys]];
}

- (NSArray *)allKeys
{
    NSArray *allProperties = [NSArray arrayWithObjects:@"accountUUID", @"objectId", @"originalPath", @"originalName", nil];
    NSMutableArray *keys = [NSMutableArray array];

    for (NSString *property in allProperties)
    {
        if ([self valueForKey:property] != nil)
        {
            [keys addObject:property];
        }
    }
    return [NSArray arrayWithArray:keys];
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key {
    ODSLogDebug(@"undefinedKey:%@", key);
}

@end
