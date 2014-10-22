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
//  ConnectivityManager.m
//

#import "ConnectivityManager.h"

@implementation ConnectivityManager
@synthesize internetReach = _internetReach;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _internetReach = nil;
}

- (id)init
{
    self = [super init];
    if(self)
    {        
        // Set up internet reach property
        _internetReach = [Reachability reachabilityForInternetConnection];
                          
        // Enable the status notifications
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [self.internetReach startNotifier];
    }
    return self;
}

/*
 Currently the notifications only contains dummy/shell code
 If no action is required when the internet reachability changed maybe we can remove the notifications.
 */
- (void)reachabilityChanged:(NSNotification *)note 
{
    Reachability *reachability = [note object];
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    if(reachability == self.internetReach)
    {
        //If we need to take some action when we have/loss internet connection
        //we should put the code in here
    }
}

- (BOOL)hasInternetConnection
{
    return [self.internetReach currentReachabilityStatus] != NotReachable;
}


+ (ConnectivityManager *)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}
@end
