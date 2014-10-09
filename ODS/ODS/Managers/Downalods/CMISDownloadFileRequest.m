//
//  CMISDownloadFileRequest.m
//  ODS
//
//  Created by bdt on 9/18/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CMISDownloadFileRequest.h"

#import "DownloadInfo.h"
#import "CMISSession.h"

@implementation CMISDownloadFileRequest

+(CMISDownloadFileRequest *)cmisDownloadRequestWithDownloadInfo:(DownloadInfo *)downloadInfo {
    CMISDownloadFileRequest *newRequest = [[CMISDownloadFileRequest alloc] init];
    [newRequest setDownloadInfo:downloadInfo];
    
    return newRequest;
}

- (void) clearDelegatesAndCancel {
    self.queue = nil;
    
    [super clearDelegatesAndCancel];
}

#pragma mark -
#pragma mark Main Loop

- (void) main {
    @autoreleasepool {
        
        @try {
            [self downloadStarted];
            CMISSessionParameters *params = [CMISUtility sessionParametersWithAccount:[[self downloadInfo] selectedAccountUUID] withRepoIdentifier:[[self downloadInfo] repositoryIdentifier]];
            self.currentRequest = [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *session, NSError *sessionError) {
                if (session == nil) {
                    self.error = sessionError;
                    ODSLogError(@"%@", sessionError);
                    [self downloadFailed];
                }else {
                    self.currentRequest = [session downloadContentOfCMISObject:[[self downloadInfo] cmisObjectId] toFile:@""
                                                               completionBlock:^(NSError *error){
                                                                   if (error) {
                                                                       ODSLogError(@"%@", error);
                                                                       self.error = error;
                                                                       [self downloadFailed];
                                                                   }else {
                                                                       [self downloadFinished];
                                                                   }
                                                                } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal){
                                                                    [self performSelectorInBackground:@selector(updateDownloadProgress) withObject:self];
                                                                }];
                }
            }];
        }
        @catch (NSException *exception) {
            ODSLogDebug(@"Download file request exception:%@", exception);
            [self downloadFailed];
        }
        @finally {
            
        }
        
        //waiting for uploading finish
        while (![self complete]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        ODSLogDebug(@"Download file request finished.");
        
    }
}

#pragma mark -
#pragma Helpers
- (void) downloadStarted {
    [[self downloadInfo] setDownloadStatus:DownloadInfoStatusDownloading];
}

- (void) downloadFinished {
    [self setComplete:YES];
    [[self downloadInfo] setDownloadStatus:DownloadInfoStatusDownloaded];
}

- (void) downloadFailed {
    [self setComplete:YES];
    [[self downloadInfo] setDownloadStatus:DownloadInfoStatusFailed];
}

- (void) updateDownloadProgress {
    dispatch_main_sync_safe(^{
        UIProgressView *uploadIndicator = (UIProgressView *)self.downloadProgressDelegate;
        float amount = (self.downloadedBytes*1.0f)/self.totalBytes;
        [uploadIndicator setProgress:amount];
    });
}

@end
