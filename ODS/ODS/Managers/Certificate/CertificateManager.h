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
//  CertificateManager.h
//
//
// Manages the access and persistence operations of certificates
// and identities.
// It uses the C functions provided by apple to search, import and store certificates
// This is a singleton since there is no need to have multiple CertificateManager instances
// storing and accessing certificate/identity items.
// All operations are available to manage identities or certificates

typedef enum {
    ImportCertificateStatusCancelled,
    ImportCertificateStatusFailed,
    ImportCertificateStatusSucceeded
} ImportCertificateStatus;

#import <Foundation/Foundation.h>
@class FDCertificate;
@class DataKeychainItemWrapper;

@interface CertificateManager : NSObject

/*
 Inits the object with a keychainWrapper.
 
 The keychainWrapper is used to retrieve and store certificate information and link
 it to an accountUUID
 */
- (id)initWithKeychainWrapper:(DataKeychainItemWrapper *)keychainWrapper;

/*
 Validates a certificate or a PKCS12 file. It will import them in memory and validate
 for a wrong file or passcode (only for PKCS12)
 */
- (ImportCertificateStatus)validatePKCS12:(NSData *)pkcs12Data withPasscode:(NSString *)passcode;

/*
 Saves the identity (PKC12) data into the keychain.
 
 Returns the status of the save operation
 */
- (ImportCertificateStatus)saveIdentityData:(NSData *)identityData withPasscode:(NSString *)passcode forAccountUUID:(NSString *)accountUUID;

/*
 Retrieves the identity wrapper from the keychain.
 PKCS12 data is associated with an accountUUID in the keychain, after reading the data
 it is evaluated and imported
 Returns the FDCertificate wrapper for the pkcs12 data
 */
- (FDCertificate *)certificateForAccountUUID:(NSString *)accountUUID;

/*
 Deletes the identity or certificate from the keychain with the accountUUID as the key
 */
- (void)deleteCertificateForAccountUUID:(NSString *)accountUUID;

/*
 Shared instance of the CertificateManager uses the keychain
 as the store to save and retrieve certificates and identities
 */
+ (id)sharedManager;

@end
