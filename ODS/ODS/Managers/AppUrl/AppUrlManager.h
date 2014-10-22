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
//  AppUrlManager.h
//  ODS
//
//  Created by bdt on 10/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppUrlHandlerProtocol <NSObject>
/*
 Returns the URL prefix ("scheme://host") the handler will accept.
 defaultAppScheme will be of the format "scheme://"
 */
- (NSString *)handledUrlPrefix:(NSString *)defaultAppScheme;
/*
 Performs the operation on the input url.
 i.e. Add an account, handle an incoming file, activate an account.
 */
- (void)handleUrl:(NSURL *)url annotation:(id)annotation;
@end

@interface AppUrlManager : NSObject
{
    // We hold a dictionary of handlers (implenting the AppUrlHandlerProtocol protocol)
    // The key is the host they handle so we can easily retrieve the handler needed
    // for a certain host.
    NSDictionary *_handlers;
}

/*
 Initializes an AppUrlManager instance with a list of url handlers
 */
- (id)initWithHandlers:(NSArray *)handlers;

/*
 Handles an incoming app url.
 It will delegate the work to a certain handler determined by the url's host.
 */
- (BOOL)handleUrl:(NSURL *)url annotation:(id)annotation;

// Shared default instance of the AppUrlManager class
+ (AppUrlManager *)sharedManager;

@end

