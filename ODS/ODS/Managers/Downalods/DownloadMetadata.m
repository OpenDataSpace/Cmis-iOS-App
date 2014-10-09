//
//  DownloadMetadata.m
//  ODS
//
//  Created by bdt on 9/18/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadMetadata.h"
#import "DownloadManager.h"

@interface DownloadMetadata()
@property (nonatomic, retain, readwrite) NSMutableDictionary *downloadInfo;
@end

@implementation DownloadMetadata
- (id)initWithDownloadInfo: (NSDictionary *) downInfo
{
    self = [super init];
    if (self)
    {
        self.downloadInfo = [NSMutableDictionary dictionaryWithDictionary:downInfo];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.downloadInfo = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)accountUUID
{
    return _downloadInfo[@"accountUUID"];
}
- (void)setAccountUUID:(NSString *)accountUUID
{
    [self setObjectIfNotNil:accountUUID forKey:@"accountUUID"];
}

- (NSString *)tenantID
{
    return _downloadInfo[@"tenantID"];
}
- (void)setTenantID:(NSString *)tenantID
{
    [self setObjectIfNotNil:tenantID forKey:@"tenantID"];
}

- (NSString *)objectId
{
    return _downloadInfo[@"objectId"];
}
- (void)setObjectId:(NSString *)objectId
{
    [self setObjectIfNotNil:objectId forKey:@"objectId"];
}

- (NSString *)filename
{
    return _downloadInfo[@"filename"];
}
- (void)setFilename:(NSString *)filename
{
    [self setObjectIfNotNil:filename forKey:@"filename"];
}

- (NSString *)versionSeriesId
{
    return _downloadInfo[@"versionSeriesId"];
}
- (void)setVersionSeriesId:(NSString *)versionSeriesId
{
    [self setObjectIfNotNil:versionSeriesId forKey:@"versionSeriesId"];
}

- (NSString *)contentStreamMimeType
{
    return _downloadInfo[@"contentStreamMimeType"];
}
- (void)setContentStreamMimeType:(NSString *)contentStreamMimeType
{
    [self setObjectIfNotNil:contentStreamMimeType forKey:@"contentStreamMimeType"];
}

- (NSString *)repositoryId
{
    return _downloadInfo[@"repositoryId"];
}
- (void)setRepositoryId:(NSString *)repositoryId
{
    [self setObjectIfNotNil:repositoryId forKey:@"repositoryId"];
}

- (NSDictionary *)metadata
{
    return _downloadInfo[@"metadata"];
}
- (void)setMetadata:(NSDictionary *)metadata
{
    [self setObjectIfNotNil:metadata forKey:@"metadata"];
}

- (NSArray *)aspects
{
    return _downloadInfo[@"aspects"];
}
- (void)setAspects:(NSArray *)aspects
{
    [self setObjectIfNotNil:aspects forKey:@"aspects"];
}

- (NSString *)describedByUrl
{
    return _downloadInfo[@"describedByUrl"];
}
- (void)setDescribedByUrl:(NSString *)describedByUrl
{
    [self setObjectIfNotNil:describedByUrl forKey:@"describedByUrl"];
}

- (NSString *)contentLocation
{
    return _downloadInfo[@"contentLocation"];
}
- (void)setContentLocation:(NSString *)contentLocation
{
    [self setObjectIfNotNil:contentLocation forKey:@"contentLocation"];
}

- (NSArray *)localComments
{
    NSArray *comments = _downloadInfo[@"localComments"];
    
    if (comments == nil)
    {
        comments = [NSArray array];
        [self setObjectIfNotNil:comments forKey:@"localComments"];
    }
    return comments;
}
- (void)setLocalComments:(NSArray *)localComments
{
    [self setObjectIfNotNil:localComments forKey:@"localComments"];
}

- (NSArray *)linkRelations
{
    return _downloadInfo[@"linkRelations"];
}
- (void)setLinkRelations:(NSArray *)linkRelations
{
    [self setObjectIfNotNil:linkRelations forKey:@"linkRelations"];
}

- (BOOL)canSetContentStream
{
    return [_downloadInfo[@"canSetContentStream"] boolValue];
}

- (void)setCanSetContentStream:(BOOL)canSetContentStream
{
    [self setObjectIfNotNil:[NSNumber numberWithBool:canSetContentStream] forKey:@"canSetContentStream"];
}

- (NSDictionary *)downloadInfo
{
    return [NSDictionary dictionaryWithDictionary:_downloadInfo];
}

- (NSString *)key
{
    if (kUseHash)
    {
        return _downloadInfo[@"versionSeriesId"];
    }
    return _downloadInfo[@"filename"];
}

- (BOOL)isMetadataAvailable
{
    return self.metadata && self.describedByUrl;
}

- (void)setObjectIfNotNil:(id)object forKey:(NSString *)key
{
    if (object != nil)
    {
        [_downloadInfo setObject:object forKey:key];
    }
}
@end
