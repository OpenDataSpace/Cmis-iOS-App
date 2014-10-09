/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
//
//  ODSConstants+Settings.h
//  ODS
//
//  Created by bdt on 8/5/14.
//  Copyright (c) 2014 OpenDataSpace. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Settings Identifier */
extern NSString * const kSettingsUseRelativeDateIdentifier;
extern NSString * const kSettingsUseDownloadCacheIdentifier;
extern NSString * const kSettingsShowHiddenFilesIdentifier;

/* Advanced Settings Identifier */
extern NSString * const kSettingsResetOnNextStartIdentifier;
extern NSString * const kSettingsValidateSSLCertIdentifier;

/* Application Session Settings Identifier */
extern NSString * const kSettingsForgetPasswordIdentifier;
extern NSString * const kSettingsLockWhenInactiveIdentifier;

/* Enterprise Settings Identifier */
extern NSString * const kSettingsDataProtectionIdentifier;

/* Diagnositic Data Settings Identifier */
extern NSString * const kSettingsSendReportsIdentifier;

@interface ODSConstants_Settings : NSObject

@end
