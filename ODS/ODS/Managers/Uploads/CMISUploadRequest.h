//
//  CMISUploadRequest.h
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadInfo.h"
#import "ODSBaseRequest.h"
#import "ODSUploadQueue.h"

@class CMISUploadQueue;

@interface CMISUploadRequest : ODSBaseRequest

@property (nonatomic, strong) UploadInfo *uploadInfo;

@property (strong, nonatomic) ODSUploadQueue   *queue;

+(CMISUploadRequest*)cmisUploadRequestWithUploadInfo:(UploadInfo*) info;

- (void) clearDelegatesAndCancel;
@end
