//
//  CMISUtility.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISSessionParameters;

@interface CMISUtility : NSObject
+ (NSArray*) filterRepositories:(NSArray*) repos;

+ (NSString*) cmisProtocolToString:(NSNumber *)cmisType;

+ (NSString*) defaultCmisDocumentServicePathWithType:(NSInteger) type;

+ (CMISSessionParameters*) sessionParametersWithAccount:(NSString*) acctUUID withRepoIdentifier:(NSString*) repoIdentifier;
@end
