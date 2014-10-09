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
//  NoFileProtectionStrategy.m
//

#import "NoFileProtectionStrategy.h"

@implementation NoFileProtectionStrategy

- (BOOL)setProtection:(NSString *)protection toFileAtPath:(NSString *)path
{
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    BOOL success = YES;
    if(![[attributes objectForKey:NSFileProtectionKey] isEqualToString:protection])
    {
        attributes = [NSDictionary dictionaryWithObject:protection forKey:NSFileProtectionKey];
        success = [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:path error:&error];
        
        if(error)
        {
            ODSLogDebug(@"Failed to protect file %@, with error: %@", path, [error description]);
        }
    }
    
    return success;
}

- (BOOL)completeProtectionForFileAtPath:(NSString *)path
{
    return [self setProtection:NSFileProtectionNone toFileAtPath:path];

}

- (BOOL)completeUnlessOpenProtectionForFileAtPath:(NSString *)path
{
    return [self setProtection:NSFileProtectionNone toFileAtPath:path];
}

@end
