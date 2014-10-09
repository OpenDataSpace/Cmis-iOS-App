//
//  DownloadMetadata.h
//  ODS
//
//  Created by bdt on 9/18/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadMetadata : NSObject
@property (nonatomic, retain, readonly) NSMutableDictionary *downloadInfo;
@property (nonatomic, retain) NSString *accountUUID;
@property (nonatomic, retain) NSString *tenantID;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *versionSeriesId;
@property (nonatomic, retain) NSString *contentStreamMimeType;
@property (nonatomic, retain) NSString *repositoryId;
@property (nonatomic, retain) NSDictionary *metadata;
@property (nonatomic, retain) NSArray *aspects;
@property (nonatomic, retain) NSString *describedByUrl;
@property (nonatomic, retain) NSString *contentLocation;
@property (nonatomic, retain) NSArray *localComments;
@property (nonatomic, retain) NSArray *linkRelations;
@property (nonatomic, assign) BOOL canSetContentStream;

- (id)initWithDownloadInfo:(NSDictionary *)downInfo;
- (BOOL)isMetadataAvailable;

- (NSString *)key;
@end
