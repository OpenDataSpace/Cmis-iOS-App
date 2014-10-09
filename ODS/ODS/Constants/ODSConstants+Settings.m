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
//  ODSConstants+Settings.m
//  ODS
//
//  Created by bdt on 8/5/14.
//  Copyright (c) 2014 OpenDataSpace. All rights reserved.
//

#import "ODSConstants+Settings.h"

/* Default Settings Identifier */
NSString * const kSettingsUseRelativeDateIdentifier = @"useRelativeDate";
NSString * const kSettingsUseDownloadCacheIdentifier = @"useDownloadCache";
NSString * const kSettingsShowHiddenFilesIdentifier = @"showHiddenFiles";

/* Advanced Settings Identifier */
NSString * const kSettingsResetOnNextStartIdentifier = @"resetToDefault";
NSString * const kSettingsValidateSSLCertIdentifier = @"validateSSLCertificate";

/* Application Session Settings Identifier */
NSString * const kSettingsForgetPasswordIdentifier = @"sessionForgetTimeout";
NSString * const kSettingsLockWhenInactiveIdentifier = @"sessionForgetWhenInactive";

/* Enterprise Settings Identifier */
NSString * const kSettingsDataProtectionIdentifier = @"dataProtectionEnabled";

/* Diagnositic Data Settings Identifier */
NSString * const kSettingsSendReportsIdentifier = @"sendDiagnosticData";

@implementation ODSConstants_Settings

@end
