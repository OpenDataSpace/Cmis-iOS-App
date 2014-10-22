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
//  ConnectivityManager.h
//
// Provides methods to determine the current state of the Internet Connectivity of the device.
// It is an observer for Reachability notifications and can potentially perform some custom code when
// the internet is reachable/non-reachable
// 

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ConnectivityManager : NSObject

/*
 Reachability instance used to keep track of the internetReach, it should be always valid
 i.e. is a shared object managed by the Reachability class
 */
@property (nonatomic, retain) Reachability *internetReach;
/*
 Returns YES if the internet is reachable either by WiFi or WWAN
 NO if the internet is NotReachable
 see NetworkStatus enum
 */
@property (nonatomic, readonly) BOOL hasInternetConnection;

/*
 Shared instance that contains an instance of Reachability initialized with
 the [Reachability reachabilityForInternetConnection] selector
 */
+ (ConnectivityManager *)sharedManager;
@end
