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
//  AccountInfo.m
//

#import "AccountInfo.h"
//#import "AppProperties.h"
#import "AccountStatusService.h"
#import "CertificateManager.h"

NSString * const kServerAccountId = @"kServerAccountId";
NSString * const kServerVendor = @"kServerVendor";
NSString * const kServerDescription = @"kServerDescription";
NSString * const kServerProtocol = @"kServerProtocol";
NSString * const kServerHostName = @"kServerHostName";
NSString * const kServerPort = @"kServerPort";
NSString * const kServerServiceDocumentRequestPath = @"kServerServiceDocumentRequestPath";
NSString * const kServerUsername = @"kServerUsername";
NSString * const kUserFirstName = @"kServerFirstName";
NSString * const kUserLastName = @"kServerLastName";
NSString * const kServerPassword = @"kServerPassword";
NSString * const kServerInformation = @"kServerInformation";
NSString * const kServerMultitenant = @"kServerMultitenant";
NSString * const kCloudId = @"kCloudId";
NSString * const kCloudKey = @"kCloudKey";
NSString * const kServerStatus = @"kServerStatus";
NSString * const kIsDefaultAccount = @"kIsDefaultAccount";
NSString * const kServerIsQualifying = @"kServerIsQualifying";
NSString * const kServerCMISProtocol = @"kServerCMISProtocol";

@implementation AccountInfo
@synthesize uuid = _uuid;
@synthesize vendor = _vendor;
@synthesize description = _description;
@synthesize protocol = _protocol;
@synthesize hostname = _hostname;
@synthesize port = _port;
@synthesize serviceDocumentRequestPath = _serviceDocumentRequestPath;
@synthesize username = _username;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize password = _password;
@synthesize infoDictionary = _infoDictionary;
@synthesize multitenant = _multitenant;
@synthesize cloudId = _cloudId;
@synthesize cloudKey = _cloudKey;
@synthesize isDefaultAccount = _isDefaultAccount;
@synthesize isQualifyingAccount = _isQualifyingAccount;
@synthesize accountStatusInfo = _accountStatusInfo;
@synthesize cmisType = _cmisType;

#pragma mark Object Lifecycle
- (void)dealloc
{
    _uuid = nil;
    _vendor = nil;
    _description = nil;
    _protocol = nil;
    _hostname = nil;
    _port = nil;
    _serviceDocumentRequestPath = nil;
    _username = nil;
    _firstName = nil;
    _lastName = nil;
    _password = nil;
    _infoDictionary = nil;
    _cloudId = nil;
    _cloudKey = nil;
    _multitenant = nil;
    _accountStatusInfo = nil;
    _cmisType = nil;

}


#pragma mark -
#pragma mark NSCoding
- (id)init 
{
    // TODO static NSString objects
    
    self = [super init];
    if(self) {
        _uuid = [NSString generateUUID];
        
        [self setCmisType:[NSNumber numberWithInteger:CMISBindingTypeAtomPub]];
        [self setServiceDocumentRequestPath:[CMISUtility defaultCmisDocumentServicePathWithType:CMISBindingTypeAtomPub]];  //for open data space
        [self setPort:kFDHTTPS_DefaultPort];
        [self setProtocol:kFDHTTPS_Protocol];
        [self setMultitenant:[NSNumber numberWithBool:NO]];
        AccountStatus *accountStatus = [[AccountStatus alloc] init];
        [accountStatus setUuid:_uuid];
        [accountStatus setAccountStatus:FDAccountStatusActive];
        [self setAccountStatusInfo:accountStatus];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) 
    {
        _uuid = [aDecoder decodeObjectForKey:kServerAccountId];
        if (nil == _uuid) {
            // We Should never get here.
            _uuid = [NSString generateUUID];
        }
        
        _vendor = [aDecoder decodeObjectForKey:kServerVendor];
        _description = [aDecoder decodeObjectForKey:kServerDescription];
        _protocol = [aDecoder decodeObjectForKey:kServerProtocol];
        _hostname = [aDecoder decodeObjectForKey:kServerHostName];
        _port = [aDecoder decodeObjectForKey:kServerPort];
        _serviceDocumentRequestPath = [aDecoder decodeObjectForKey:kServerServiceDocumentRequestPath];
        _username = [aDecoder decodeObjectForKey:kServerUsername];
        _firstName = [aDecoder decodeObjectForKey:kUserFirstName];
        _lastName = [aDecoder decodeObjectForKey:kUserLastName];
        _password = [aDecoder decodeObjectForKey:kServerPassword];
        _infoDictionary = [aDecoder decodeObjectForKey:kServerInformation];
        _multitenant = [aDecoder decodeObjectForKey:kServerMultitenant];
        _cloudId = [aDecoder decodeObjectForKey:kCloudId];
        _cloudKey = [aDecoder decodeObjectForKey:kCloudKey];
        _isDefaultAccount = [[aDecoder decodeObjectForKey:kIsDefaultAccount] intValue];
        _isQualifyingAccount = [[aDecoder decodeObjectForKey:kServerIsQualifying] boolValue];
        _cmisType = [aDecoder decodeObjectForKey:kServerCMISProtocol];
        
        _accountStatusInfo = [[AccountStatusService sharedService] accountStatusForUUID:_uuid];
        if(!_accountStatusInfo)
        {
            // NO account status stored, creating an AccountStatus object
            FDAccountStatus accountStatus = [[aDecoder decodeObjectForKey:kServerStatus] intValue];
            _accountStatusInfo = [[AccountStatus alloc] init];
            [_accountStatusInfo setAccountStatus:accountStatus];
            [_accountStatusInfo setUuid:_uuid];
            [[AccountStatusService sharedService] saveAccountStatus:_accountStatusInfo];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_uuid forKey:kServerAccountId];
    [aCoder encodeObject:_vendor forKey:kServerVendor];
    [aCoder encodeObject:_description forKey:kServerDescription];
    [aCoder encodeObject:_protocol forKey:kServerProtocol];
    [aCoder encodeObject:_hostname forKey:kServerHostName];
    [aCoder encodeObject:_port forKey:kServerPort];
    [aCoder encodeObject:_serviceDocumentRequestPath forKey:kServerServiceDocumentRequestPath];
    [aCoder encodeObject:_username forKey:kServerUsername];
    [aCoder encodeObject:_firstName forKey:kUserFirstName];
    [aCoder encodeObject:_lastName forKey:kUserLastName];
    [aCoder encodeObject:_password forKey:kServerPassword];
    [aCoder encodeObject:_infoDictionary forKey:kServerInformation];
    [aCoder encodeObject:_multitenant forKey:kServerMultitenant];
    [aCoder encodeObject:_cloudId forKey:kCloudId];
    [aCoder encodeObject:_cloudKey forKey:kCloudKey];
    [aCoder encodeObject:_cmisType forKey:kServerCMISProtocol];
    [aCoder encodeObject:[NSNumber numberWithBool:_isDefaultAccount] forKey:kIsDefaultAccount];
    [aCoder encodeObject:[NSNumber numberWithBool:_isQualifyingAccount] forKey:kServerIsQualifying];
}

- (BOOL)isMultitenant
{
    return [_multitenant boolValue];
}

- (BOOL)isLiveCloudEnvironment
{
    // Get the default values for alfresco cloud
    NSString *path = [[NSBundle mainBundle] pathForResource:kDefaultAccountsPlist_FileName ofType:@"plist"];
    NSDictionary *defaultAccountsPlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSDictionary *defaultCloudValues = defaultAccountsPlist[@"kDefaultCloudAccountValues"];
    NSString *defaultCloudHostname = defaultCloudValues[@"Hostname"];

    return [self.hostname isEqualToCaseInsensitiveString:defaultCloudHostname];
}

- (FDAccountStatus)accountStatus
{
    return [self.accountStatusInfo accountStatus];
}

- (void)setAccountStatus:(FDAccountStatus)accountStatus
{
    [self.accountStatusInfo setAccountStatus:accountStatus];
}

- (FDCertificate *)certificateWrapper
{
    return [[CertificateManager sharedManager] certificateForAccountUUID:self.uuid];
}

#pragma mark -
#pragma mark K-V Compliance

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

#pragma mark - Special requirements  - Excluded accounts
- (void)setIsQualifyingAccount:(BOOL)newIsQualifyingAccount
{
    // We want to set the property to NO if the current account is an excluded qualifying account for data protection.
    // Since the demo account is an enterprise account we always try to offer data protection. We need to exlude the account for data protection
//    if(newIsQualifyingAccount && [AppProperties isExcludedAccount:self])
//    {
//        newIsQualifyingAccount = NO;
//    }
    //TODO:not implement
    _isQualifyingAccount = newIsQualifyingAccount;
}

// Ignore the undefined keys
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    return;
}


@end
