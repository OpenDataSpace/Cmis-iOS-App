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
//  FileProtectionManager.h
//
// Provides a set of utility methods to protect or read a file protected.
// Since certain files or targets will not use protection, this class uses a strategy pattern
// to handle all of the cases (Configurable property, not all repositories should support file protection, etc.)

#import <Foundation/Foundation.h>
@class ProgressAlertView;
@protocol FileProtectionStrategyProtocol;

@interface FileProtectionManager : NSObject <UIAlertViewDelegate>

/*
 Used to display a UI when the user is waiting that the app protects all of the current (unprotected) files in the download folder.
 */
@property (nonatomic, retain) ProgressAlertView *progressAlertView;

/*
 Add complete protection to a file in the "path" parameter.
 If the file is already protected, the method will only return YES (and will not try to protect it again)
 */
- (BOOL)completeProtectionForFileAtPath:(NSString *)path;
/*
 Add complete unless open protection to a file in the "path" parameter.
 If the file is already protected, the method will only return YES (and will not try to protect it again)
 */
- (BOOL)completeUnlessOpenProtectionForFileAtPath:(NSString *)path;
/*
 Determines if the file protection is enabled.
 */
- (BOOL)isFileProtectionEnabled;
/*
 It lets the FileProtectionManager know that an enterprise account was detected. If it's the first account detected it will prompt the user
 to enable or disable data protection.
 */
- (void)enterpriseAccountDetected;

+ (FileProtectionManager *)sharedInstance;
@end
