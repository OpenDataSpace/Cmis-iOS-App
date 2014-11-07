//
//  CMISUtility.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CMISUtility.h"
#import "CMISSessionParameters.h"
#import "CMISFolder.h"
#import "CMISConstants.h"
#import "CMISOperationContext.h"
#import "CMISProperties.h"
#import "CMISPropertyData.h"
#import "CMISConstants+ODS.h"
#import "NSString+SHA.h"
#import "ConnectivityManager.h"
#import "CMISErrors.h"
#import "Utility.h"

@implementation CMISUtility

+ (NSArray*) filterRepositories:(NSArray*) repos {
    NSMutableArray *repoArr = [NSMutableArray array];
    
    for (CMISRepositoryInfo *repoInfo in repos)
    {
        if ([repoInfo.name caseInsensitiveCompare:@"config"] == NSOrderedSame) { //TODO:disable config and backup repo.
            continue;
        }
        
        //list repositories in order:my shared global
        if ([repoInfo.name isEqualToString:@"my"]) {
            [repoArr insertObject:repoInfo atIndex:0];
        }else if ([repoInfo.name isEqualToString:@"shared"]) {
            if ([repoArr count] == 0) {
                [repoArr insertObject:repoInfo atIndex:0];
            }else {
                CMISRepositoryInfo *firstRepo = [repoArr objectAtIndex:0];
                if ([firstRepo.name isEqualToString:@"my"]) {
                    [repoArr insertObject:repoInfo atIndex:1];
                }else {
                    [repoArr insertObject:repoInfo atIndex:0];
                }
            }
        } else {
            [repoArr addObject:repoInfo];
        }
    }
    
    return repoArr;
}

+ (NSString*) cmisProtocolToString:(NSNumber *)cmisType {
    NSString *protocolString = nil;
    if ([cmisType integerValue] == CMISBindingTypeAtomPub) {
        protocolString = NSLocalizedString(@"cmis.binding.type.atompub", @"Atompub");
    }else if ([cmisType integerValue] == CMISBindingTypeBrowser) {
        protocolString = NSLocalizedString(@"cmis.binding.type.browser", @"Browser");
    }
    
    return protocolString;
}

+ (NSString*) defaultCmisDocumentServicePathWithType:(NSInteger) type {
    if (type == CMISBindingTypeAtomPub) {
        return @"/cmis/atom11";
    }else if (type == CMISBindingTypeBrowser) {
        return @"/cmis/browser";
    }
    return @"";
}

+ (CMISSessionParameters*) sessionParametersWithAccount:(NSString*) acctUUID withRepoIdentifier:(NSString*) repoIdentifier {
    CMISSessionParameters *sessionParameters = getSessionParametersWithAccountUUID(acctUUID, repoIdentifier);
    if (sessionParameters == nil) {
        ODSLogError(@"Create session prarameters for account %@ fail.", acctUUID);
    }
    
    return sessionParameters;
}

/* Rename File or Folder */
+ (void) renameWithItem:(CMISObject*) item newName:(NSString*) newName withCompletionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:newName, kCMISPropertyName, nil];
    [item updateProperties:param completionBlock:^(CMISObject *object, NSError *error) {
        if (completionBlock) {
            completionBlock(object, error);
        }
    }];
}

/* Dictionary to CMIS Properties */
+ (CMISProperties*) linkParametersToCMISProperties:(NSDictionary*) params {
    CMISProperties *properties = [[CMISProperties alloc] init];
    NSArray *allKeys = [params allKeys];
    
    for (NSString *key in allKeys) {
        id param = [params objectForKey:key];
        if (param != nil) {
            if ([param isKindOfClass:[NSString class]]) {
                if ([key isEqualToCaseInsensitiveString:kCMISPropertyGDSPasswordId]) {
                    [properties addProperty:[CMISPropertyData createPropertyForId:key stringValue:[NSString SHA256String:param]]];
                }else {
                    [properties addProperty:[CMISPropertyData createPropertyForId:key stringValue:param]];
                }
            }else if ([param isKindOfClass:[NSDate class]]) {
                [properties addProperty:[CMISPropertyData createPropertyForId:key dateTimeValue:param]];
            }else if ([param isKindOfClass:[NSArray class]] && [key isEqualToCaseInsensitiveString:kCMISPropertyGDSObjectIdsId]) {  //gds:objectIds
                [properties addProperty:[CMISPropertyData createPropertyForId:key arrayValue:param type:CMISPropertyTypeId]];
            }
        }        
    }
    
    [properties addProperty:[CMISPropertyData createPropertyForId:kCMISPropertyObjectTypeId idValue:@"cmis:item"]];
    [properties addProperty:[CMISPropertyData createPropertyForId:kCMISPropertySecondaryObjectTypeIds arrayValue:[NSArray arrayWithObjects:@"gds:downloadLink", @"cmis:rm_clientMgtRetention", nil] type:CMISPropertyTypeString]];
    
    
    return properties;
}

/* Handle CMIS request error message */
+ (void) handleCMISRequestError:(NSError*) theError {
    dispatch_main_sync_safe(^{
        if ([theError.domain isEqualToString:kCMISErrorDomainName])
        {
            if (theError.code == kCMISErrorCodePermissionDenied)
            {
                NSString *authenticationFailureMessageForAccount = NSLocalizedString(@"authenticationFailureMessageForAccount", @"Please check your username and password in the iPhone settings for ODS");
                displayErrorMessageWithTitle(authenticationFailureMessageForAccount, NSLocalizedString(@"authenticationFailureTitle", @"Authentication Failure Title Text 'Authentication Failure'"));
            }else {
                displayErrorMessage([theError localizedFailureReason]);
            }
        }
        else
        {
            ODSLogDebug(@"%@", theError);
        }
    });
}

@end
