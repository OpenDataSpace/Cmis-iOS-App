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
//  AccountUtils.m
//

#import "AccountUtils.h"
#import "AccountInfo.h"

NSString * const kAccountUuidKey = @"uuid";
NSString * const kAccountDescriptionKey = @"description";
NSString * const kAccountHostnameKey = @"hostname";
NSString * const kAccountPortKey = @"port";
NSString * const kAccountProtocolKey = @"protocol";
NSString * const kAccountBoolProtocolKey = @"boolProtocol";
NSString * const kAccountMultitenantKey = @"multitenant";
NSString * const kAccountMultitenantStringKey = @"multitentant";
NSString * const kAccountUsernameKey = @"username";
NSString * const kAccountPasswordKey = @"password";
NSString * const kAccountConfirmPasswordKey = @"confirmPassword";
NSString * const kAccountVendorKey = @"vendor";
NSString * const kAccountServiceDocKey = @"serviceDocumentRequestPath";
NSString * const kAccountFirstNameKey = @"firstName";
NSString * const kAccountLastNameKey = @"lastName";
NSString * const kAccountServerInformationKey = @"serverInformation";
NSString * const kAccountBoolStatusKey = @"boolStatus";
NSString * const kAccountClientCertificateKey = @"clientCertificate";
NSString * const kAccountCMISProtocolKey = @"CMISProtocol";  //Atompub, Browser binding

@implementation AccountUtils

+ (NSDictionary *)dictionaryFromAccount:(AccountInfo *)account
{
    NSDictionary *accountDict = [account dictionaryWithValuesForKeys:[NSArray arrayWithObjects:kAccountUuidKey, kAccountVendorKey, kAccountDescriptionKey, kAccountProtocolKey, kAccountHostnameKey, kAccountPortKey, kAccountServiceDocKey, kAccountUsernameKey, kAccountFirstNameKey, kAccountLastNameKey,  kAccountPasswordKey, kAccountMultitenantStringKey, kAccountServerInformationKey, kAccountCMISProtocolKey, nil]];
    return accountDict;
}

+ (AccountInfo *)accountFromDictionary:(NSDictionary *)accountDict
{
    AccountInfo *accountInfo = [[AccountInfo alloc] init];
    [accountInfo setValuesForKeysWithDictionary:accountDict];
    
    return accountInfo;
}
@end
