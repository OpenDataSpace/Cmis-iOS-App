//
//  PreviewCacheManager.h
//  ODS
//
//  Created by bdt on 10/17/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadInfo;
@class CMISObject;

@interface PreviewCacheManager : NSObject
//Singleton instance
+ (PreviewCacheManager *)sharedManager;

//check the file is exists
- (BOOL) previewFileExists:(CMISObject*) item;

//get cached file path
- (NSDictionary*) downloadInfoFromCache:(CMISObject*) item;

//cache new file
- (BOOL) cachePreviewFile:(DownloadInfo*) info;

//clear all cache
- (void) removeAllCacheFiles;

//Cache size
- (NSString*) previewCahceSize;

//generate cache file path
- (NSString*) generateCachePath:(CMISObject*)item;

- (NSString*) generateTempPath:(CMISObject*) item;
@end
