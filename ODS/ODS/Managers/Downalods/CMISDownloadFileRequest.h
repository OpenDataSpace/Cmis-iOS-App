//
//  CMISDownloadFileRequest.h
//  ODS
//
//  Created by bdt on 9/18/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODSBaseRequest.h"
#import "ODSDownloadQueue.h"

@class DownloadInfo;

@interface CMISDownloadFileRequest : ODSBaseRequest
@property (nonatomic, strong) DownloadInfo *downloadInfo;
@property (strong, nonatomic) ODSDownloadQueue   *queue;

+(CMISDownloadFileRequest *)cmisDownloadRequestWithDownloadInfo:(DownloadInfo *)downloadInfo;
@end
 