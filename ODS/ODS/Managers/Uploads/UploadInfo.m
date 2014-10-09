//
//  UploadInfo.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadInfo.h"
#import "CMISUploadRequest.h"

NSString * const kUploadInfoUUID = @"uuid";
NSString * const kUploadInfoFileURL = @"uploadFileURL";
NSString * const kUploadInfoFilename = @"filename";
NSString * const kUploadInfoExtension = @"extension";
NSString * const kUploadInfoUpLinkRelation = @"upLinkRelation";
NSString * const kUploadInfoCmisObjectId = @"cmisObjectId";
NSString * const kUploadInfoDate = @"uploadDate";
NSString * const kUploadInfoTags = @"tags";
NSString * const kUploadInfoStatus = @"uploadStatus";
NSString * const kUploadInfoType = @"uploadType";
NSString * const kUploadInfoError = @"error";
NSString * const kUploadInfoFolderName = @"folderName";
NSString * const kUploadInfoSelectedAccountUUID = @"selectedAccountUUID";
NSString * const kUploadInfoTenantID = @"tenantID";
NSString * const kUploadInfoUploadFileIsTemporary = @"uploadFileIsTemporary";

@implementation UploadInfo

#pragma mark -
#pragma mark NSCoding
- (id)init
{
    // TODO static NSString objects
    
    self = [super init];
    if(self) {
        [self setUuid:[NSString generateUUID]];
        [self setUploadDate:[NSDate date]];
        [self setUploadStatus:UploadInfoStatusInactive];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        [self setUuid:[aDecoder decodeObjectForKey:kUploadInfoUUID]];
        if (nil == _uuid) {
            // We Should never get here.
            [self setUuid:[NSString generateUUID]];
        }
        
        [self setUploadFileURL:[aDecoder decodeObjectForKey:kUploadInfoFileURL]];
        [self setFilename:[aDecoder decodeObjectForKey:kUploadInfoFilename]];
        [self setExtension:[aDecoder decodeObjectForKey:kUploadInfoExtension]];
        [self setCmisObjectId:[aDecoder decodeObjectForKey:kUploadInfoCmisObjectId]];
        [self setUploadDate:[aDecoder decodeObjectForKey:kUploadInfoDate]];
        [self setUploadStatus:[[aDecoder decodeObjectForKey:kUploadInfoStatus] intValue]];
        [self setUploadType:[[aDecoder decodeObjectForKey:kUploadInfoType] intValue]];
        [self setError:[aDecoder decodeObjectForKey:kUploadInfoError]];
        [self setFolderName:[aDecoder decodeObjectForKey:kUploadInfoFolderName]];
        [self setSelectedAccountUUID:[aDecoder decodeObjectForKey:kUploadInfoSelectedAccountUUID]];
        [self setUploadFileIsTemporary:[aDecoder decodeBoolForKey:kUploadInfoUploadFileIsTemporary]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uuid forKey:kUploadInfoUUID];
    [aCoder encodeObject:self.uploadFileURL forKey:kUploadInfoFileURL];
    [aCoder encodeObject:self.filename forKey:kUploadInfoFilename];
    [aCoder encodeObject:self.extension forKey:kUploadInfoExtension];
    [aCoder encodeObject:self.cmisObjectId forKey:kUploadInfoCmisObjectId];
    [aCoder encodeObject:self.uploadDate forKey:kUploadInfoDate];
    [aCoder encodeObject:[NSNumber numberWithInt:self.uploadStatus] forKey:kUploadInfoStatus];
    [aCoder encodeObject:[NSNumber numberWithInt:self.uploadType] forKey:kUploadInfoType];
    [aCoder encodeObject:self.error forKey:kUploadInfoError];
    [aCoder encodeObject:self.folderName forKey:kUploadInfoFolderName];
    [aCoder encodeObject:self.selectedAccountUUID forKey:kUploadInfoSelectedAccountUUID];
    [aCoder encodeBool:self.uploadFileIsTemporary forKey:kUploadInfoUploadFileIsTemporary];
}

- (NSString *)completeFileName {
    if (self.extension == nil || [self.extension isEqualToString:@""])
    {
        return self.filename;
    }
    
    return [self.filename stringByAppendingPathExtension:self.extension];
}

- (BOOL) sourceFileExists {
    return YES;
}

- (float) uploadedProgress {
    if (self.uploadRequest && self.uploadRequest.totalBytes > 0) {
        return (self.uploadRequest.sentBytes/self.uploadRequest.totalBytes);
    }
    
    return 0.0f;
}

@end
