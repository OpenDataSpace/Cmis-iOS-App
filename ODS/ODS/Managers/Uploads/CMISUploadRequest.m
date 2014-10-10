//
//  CMISUploadRequest.m
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>

#if TARGET_OS_IPHONE
#import <MobileCoreServices/UTType.h>
#import <UIKit/UIDevice.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#import "ALAssetInputStream.h"
#import "CMISUploadRequest.h"

#import "CMISConstants.h"
#import "CMISSession.h"
#import "CMISBrowserBinding.h"
#import "CMISRequest.h"

@interface CMISUploadRequest()
@property (nonatomic, assign) NSUInteger    fileSize;
@property (nonatomic, strong) CMISSession   *uploadSession;
@end

@implementation CMISUploadRequest
@synthesize fileSize = _fileSize;

+(CMISUploadRequest*)cmisUploadRequestWithUploadInfo:(UploadInfo*) info {
    CMISUploadRequest *newRequest = [[CMISUploadRequest alloc] init];
    
    [newRequest setUploadInfo:info];
    
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
            [self uploadStart];
            CMISSessionParameters *params = [CMISUtility sessionParametersWithAccount:[[self uploadInfo] selectedAccountUUID] withRepoIdentifier:[[self uploadInfo] repositoryIdentifier]];
            self.currentRequest = [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *session, NSError *sessionError) {
                if (session == nil) {
                    self.error = sessionError;
                    ODSLogError(@"%@", sessionError);
                    [self uploadFailed];
                }else {
                    NSInputStream *uploadStream = [self prepareUploadStream];
                    NSString *mimeType = [self mimeTypeFromFileExtension];
                    NSDictionary *properties = [self uploadProperties];
                    
                    if (uploadStream == nil) {
                        ODSLogInfo(@"Prepare upload stream fail.");
                        [self uploadFailed];
                        return ;
                    }
                    
                    self.uploadSession = session;
                    
                    [self uploadStart];
                    self.currentRequest = [self.uploadSession createDocumentFromInputStream:uploadStream mimeType:mimeType properties:properties inFolder:[[self uploadInfo] targetFolderIdentifier] bytesExpected:[self fileSize] completionBlock:^(NSString *objectId, NSError * error) {
                        if (objectId) {
                            ODSLogDebug(@"create objectid:%@", objectId);
                            [[self uploadInfo] setCmisObjectId:objectId];
                            [self uploadFinish];
                        }else {
                            ODSLogError(@"create document error:%@", error);
                            self.error = error;
                            [self uploadFailed];
                        }
                    } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                        ODSLogDebug(@"bytesUploaded:%llu -- bytesTotal:%llu,  fileSize:%lu", bytesUploaded, bytesTotal, [self fileSize]);
                        [self didSendBytes:bytesUploaded total:bytesTotal];
                    }];
                }
            }];
        }
        @catch (NSException *exception) {
            ODSLogDebug(@"Upload file request exception:%@", exception);
            [self uploadFailed];
        }
        @finally {
            
        }
        
        //waiting for uploading finish
        while (![self complete]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        ODSLogDebug(@"Upload file request finished.");

    }
}


#pragma mark -
#pragma mark Upload Helpers

- (NSDictionary*) uploadProperties {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:kCMISPropertyObjectTypeIdValueDocument forKey:kCMISPropertyObjectTypeId];
    [properties setObject:[[self uploadInfo] completeFileName] forKey:kCMISPropertyName];
    
    return properties;
}

- (NSInputStream*) prepareUploadStream {
    NSInputStream *uploadStream = nil;
    NSString* urlString = [[[self uploadInfo] uploadFileURL] absoluteString];
    
    if ([urlString hasPrefix:@"asset"]) {
        ALAsset *asset = assetFromURL([[self uploadInfo] uploadFileURL]);
        if (asset == nil) {
            ODSLogError(@"Load alasset with url %@ failed.", urlString);
        }else {
            unsigned long long sizeOfFile = [[asset defaultRepresentation] size];
            ODSLogDebug(@"file size:%llu", sizeOfFile);
            [self setFileSize:(NSUInteger)sizeOfFile];
            uploadStream = (NSInputStream*)[[ALAssetInputStream alloc] initWithALAsset:asset];
            if (uploadStream == nil) {
                ODSLogError(@"Stream asset %@ failed.", urlString);
            }
            ODSLogDebug(@"file size:%llu, ==== %lu", sizeOfFile, [self fileSize]);
        }
    }else {
        unsigned long long sizeOfFile = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[[self uploadInfo] uploadFileURL] path] error:nil] fileSize];
        [self setFileSize:(NSUInteger)sizeOfFile];
        uploadStream = [NSInputStream inputStreamWithFileAtPath:[[[self uploadInfo] uploadFileURL] path]];
        if (uploadStream == nil) {
            ODSLogError(@"Stream file %@ failed.", urlString);
        }
    }
    
    return uploadStream;
}

//mimetype from file extension
- (NSString*) mimeTypeFromFileExtension {
    //get mimetype from file extension
    CFStringRef pathExtension = (__bridge_retained CFStringRef)self.uploadInfo.extension;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    
    // The UTI can be converted to a mime type:
    
    NSString* mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
    CFRelease(type);
    
    if (mimeType == nil) {
        mimeType = @"application/octet-stream";
    }
    
    return mimeType;
}

//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) didSendBytes:(long long)bytes total:(unsigned long long) bytesTotal {
    self.sentBytes = bytes;
    self.totalBytes = bytesTotal;
    if (self.queue) {
        //[self performSelector:@selector(request:didSendBytes:) onTarget:&uploadQueue withObject:self amount:&value callerToRetain:self];
        //[_queue request:self didSendBytes:value];
    }

    if ([self uploadProgressDelegate]) {
        [self performSelectorInBackground:@selector(updateProgressIndicator) withObject:self];
    }
}

- (void) uploadStart {
    [[self uploadInfo] setUploadStatus:UploadInfoStatusUploading];
    [[self cancelledLock] lock];
    
    if (self.queue && [self.queue respondsToSelector:@selector(requestStarted:)]) {
		[self.queue performSelector:@selector(requestStarted:) withObject:self];
	}
    [[self cancelledLock] unlock];
}

- (void) uploadFailed {
    [[self uploadInfo] setUploadStatus:UploadInfoStatusFailed];
    [[self cancelledLock] lock];
    
    if (self.queue && [self.queue respondsToSelector:@selector(requestFailed:)]) {
		[self.queue performSelector:@selector(requestFailed:) withObject:self];
	}
    [[self cancelledLock] unlock];
    [self setComplete:YES];
}

- (void) uploadFinish {
    [[self uploadInfo] setUploadStatus:UploadInfoStatusUploaded];
    [[self cancelledLock] lock];
    
    if (self.queue && [self.queue respondsToSelector:@selector(requestFinished:)]) {
		[self.queue performSelector:@selector(requestFinished:) withObject:self];
	}
    [[self cancelledLock] unlock];
    [self setComplete:YES];
}

- (void) updateProgressIndicator {
    dispatch_main_sync_safe(^{
        if (self.uploadProgressDelegate) {
            UIProgressView *uploadIndicator = (UIProgressView *)[self uploadProgressDelegate];
            float amount = (self.sentBytes*1.0f)/self.totalBytes;
            [uploadIndicator setProgress:amount];
        }
    });
}
@end
