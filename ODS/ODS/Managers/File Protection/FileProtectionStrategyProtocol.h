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
//  FileProtectionStrategyProtocol.h
//
// Strategy protocol used by the FileProtectionManager to handle all the different requirements in the
// file protection. Implementations:
// FileProtectionDefaultStrategy
// NoFileProtectionStrategy

#import <Foundation/Foundation.h>

@protocol FileProtectionStrategyProtocol <NSObject>
/*
 Will try to change to a complete protection to the file at the given path.
 It may be required to protect the file in a different way (i.e. protection is not available and
 no protection should be used)
 */
- (BOOL)completeProtectionForFileAtPath:(NSString *)path;
/*
 Will try to change to a complete unless open protection to the file at the given path.
 It may be required to protect the file in a different way (i.e. protection is not available and
 no protection should be used)
 */
- (BOOL)completeUnlessOpenProtectionForFileAtPath:(NSString *)path;
@end
