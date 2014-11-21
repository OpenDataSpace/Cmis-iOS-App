//
//  CMISUtility.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISSessionParameters;
@class CMISFolder;
@class CMISObject;
@class CMISRequest;
@class CMISOperationContext;
@class CMISProperties;

@interface CMISUtility : NSObject
+ (NSArray*) filterRepositories:(NSArray*) repos;

+ (NSString*) cmisProtocolToString:(NSNumber *)cmisType;

+ (NSString*) defaultCmisDocumentServicePathWithType:(NSInteger) type;

+ (CMISSessionParameters*) sessionParametersWithAccount:(NSString*) acctUUID withRepoIdentifier:(NSString*) repoIdentifier;

/* Rename File or Folder */
+ (void) renameWithItem:(CMISObject*) item newName:(NSString*) newName withCompletionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock;

/* Dictionary to CMIS Properties */
+ (CMISProperties*) linkParametersToCMISProperties:(NSDictionary*) param;

/* Handle CMIS request error message */
+ (void) handleCMISRequestError:(NSError*) theError;
+ (void) handleCMISRequestError:(NSError*) theError isAuthentication:(BOOL) isAuthentication;
@end
