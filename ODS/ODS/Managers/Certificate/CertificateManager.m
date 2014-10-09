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
//  CertificateManager.m
//
//

#import "CertificateManager.h"
#import "FDCertificate.h"
#import "DataKeychainItemWrapper.h"
//#import "NSNotificationCenter+CustomNotification.h"

NSString * const kCertificateManagerService = @"CertificateManagerService";
NSString * const kCertificateManagerIdentifier = @"CertificateManager";

@interface CertificateManager ()
@property (nonatomic, retain) NSMutableDictionary *allIdentities;
@property (nonatomic, retain) DataKeychainItemWrapper *keychainWrapper;

@end

@implementation CertificateManager
@synthesize allIdentities = _allIdentities;
@synthesize keychainWrapper = _keychainWrapper;

- (id)initWithKeychainWrapper:(DataKeychainItemWrapper *)keychainWrapper
{
    self = [super init];
    if (self)
    {
        _keychainWrapper = [keychainWrapper retain];
        NSData *serializedCertificateData = [_keychainWrapper objectForKey:(id)kSecValueData];
        if (serializedCertificateData && serializedCertificateData.length > 0)
        {
            NSMutableDictionary *deserializedDict = [NSKeyedUnarchiver unarchiveObjectWithData:serializedCertificateData];
            if (deserializedDict)
            {
                _allIdentities = [deserializedDict retain];
            }
            else
            {
                _allIdentities = [[NSMutableDictionary alloc] init];
            }
        }
    }

    return self;
}

- (ImportCertificateStatus)validatePKCS12:(NSData *)pkcs12Data withPasscode:(NSString *)passcode
{
    ImportCertificateStatus status = ImportCertificateStatusFailed;
    CFArrayRef importedItems = NULL;
    OSStatus err = SecPKCS12Import(
                          (CFDataRef) pkcs12Data,
                          (CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
                                             passcode,        kSecImportExportPassphrase,
                                             nil
                                             ],
                          &importedItems
                          );
    if (err == noErr)
    {
        status = ImportCertificateStatusSucceeded;
    }
    else if (err == errSecAuthFailed)
    {
        status = ImportCertificateStatusCancelled;
    }
    
    if (importedItems != NULL)
    {
        CFRelease(importedItems);
    }
    return status;
}

- (ImportCertificateStatus)saveIdentityData:(NSData *)identityData withPasscode:(NSString *)passcode forAccountUUID:(NSString *)accountUUID
{
    OSStatus    err;
    CFArrayRef importedItems;
    NSDictionary  *itemDict = NULL;
    
    ImportCertificateStatus status = ImportCertificateStatusFailed;
    
    importedItems = NULL;
    
    err = SecPKCS12Import(
                          (CFDataRef) identityData,
                          (CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
                                             passcode,        kSecImportExportPassphrase,
                                             nil
                                             ],
                          &importedItems
                          );
    if (err == noErr)
    {
        SecIdentityRef identity;
        // +++ If there are multiple identities in the PKCS#12, we only use the first one
        itemDict = [(NSArray *)importedItems objectAtIndex:0];
        assert([itemDict isKindOfClass:[NSDictionary class]]);
        
        identity = (SecIdentityRef) [itemDict objectForKey:(NSString *) kSecImportItemIdentity];
        assert(identity != NULL);
        // Making sure there's an actual identity in the imported items
        if ( CFGetTypeID(identity) == SecIdentityGetTypeID() )
        {
            FDCertificate *certificate = [[[FDCertificate alloc] initWithIdentityData:identityData
                                                                          andPasscode:passcode] autorelease];
            [self.allIdentities setObject:certificate forKey:accountUUID];
            [self saveAllIdentities];
            status = ImportCertificateStatusSucceeded;
        }
        else
        {
            // Unknown error/wrong identity data
            status = ImportCertificateStatusFailed;
        }
    }
    else if (err == errSecAuthFailed)
    {
        // The passcode is wrong
        status = ImportCertificateStatusCancelled;
    }
    
    if (importedItems != NULL)
    {
        CFRelease(importedItems);
    }
    
    return status;
}

- (FDCertificate *)certificateForAccountUUID:(NSString *)accountUUID
{
    return [self.allIdentities objectForKey:accountUUID];
}

- (void)deleteCertificateForAccountUUID:(NSString *)accountUUID
{
    [self.allIdentities removeObjectForKey:accountUUID];
    [self saveAllIdentities];
}

- (void)saveAllIdentities
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.allIdentities];
    [self.keychainWrapper setObject:data forKey:(id)kSecValueData];
}

#pragma mark - Singleton

+ (id)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        DataKeychainItemWrapper *keychain = [[[DataKeychainItemWrapper alloc] initWithIdentifier:kCertificateManagerIdentifier accessGroup:nil] autorelease];
        [keychain setObject:kCertificateManagerService forKey:(id)kSecAttrService];
        
        sharedObject = [[self alloc] initWithKeychainWrapper:keychain];
    });
    return sharedObject;
}

@end
