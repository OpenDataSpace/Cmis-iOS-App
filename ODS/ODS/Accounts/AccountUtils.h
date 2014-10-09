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
//  AccountUtils.h
//
// Util methods for accounts.
// It provides constants used for keys to represent an account in a dictonary and also
// methods to save an account into a dictionary and to create an account from a dictionary.

#import <Foundation/Foundation.h>
@class AccountInfo;

// Account field keys
extern NSString * const kAccountDescriptionKey;
extern NSString * const kAccountHostnameKey;
extern NSString * const kAccountPortKey;
extern NSString * const kAccountProtocolKey;
extern NSString * const kAccountBoolProtocolKey;
extern NSString * const kAccountMultitenantKey;
extern NSString * const kAccountMultitenantStringKey;
extern NSString * const kAccountUsernameKey;
extern NSString * const kAccountPasswordKey;
extern NSString * const kAccountConfirmPasswordKey;
extern NSString * const kAccountVendorKey;
extern NSString * const kAccountServiceDocKey;
extern NSString * const kAccountFirstNameKey;
extern NSString * const kAccountLastNameKey;
extern NSString * const kAccountServerInformationKey;
extern NSString * const kAccountBoolStatusKey;
extern NSString * const kAccountClientCertificateKey;

@interface AccountUtils : NSObject

// It extracts the values in the account objects and creates a dictionary
// The keys used are the same as the constats defined in this class
+ (NSDictionary *)dictionaryFromAccount:(AccountInfo *)account;
// It creates an AccountInfo object from the values in the accountDict Dictionary
// The keys used are the same as the constats defined in this class
+ (AccountInfo *)accountFromDictionary:(NSDictionary *)accountDict;
@end

