//
//  CMISUtility.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CMISUtility.h"
#import "CMISSessionParameters.h"

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
        protocolString = NSLocalizedString(@"cmis.binding.type.browse", @"Browse");
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


@end
