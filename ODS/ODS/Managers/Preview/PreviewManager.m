/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  PreviewManager.m
//

#import "PreviewManager.h"
#import "DownloadInfo.h"
#import "DownloadManager.h"
#import "FileProtectionManager.h"
//#import "PreviewCacheManager.h"

@interface PreviewManager ()
@property (nonatomic, retain, readwrite) DownloadInfo *currentDownload;
@end

@implementation PreviewManager

@synthesize delegate = _delegate;
@synthesize currentDownload = _currentDownload;
@synthesize progressIndicator = _progressIndicator;


#pragma mark - Shared Instance

+ (PreviewManager *)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

#pragma mark - Lifecycle

- (void)dealloc
{
    // This object lives for the entire life of the application, so we don't even attempt to dealloc.
    assert(NO);
}

#pragma mark - Public Methods

- (void)previewItem:(CMISObject*)item delegate:(id<PreviewManagerDelegate>)aDelegate accountUUID:(NSString *)anAccountUUID repositoryID:(NSString*)aRepositoryID tenantID:(NSString *)aTenantID
{
    DownloadManager *manager = [DownloadManager sharedManager];
    
    /**
     * mhatfield 08 jun 2012
     * TODO: Play nicely with the DownloadManager
     */
    // Does the DownloadManager already know about this item?
    DownloadInfo *managedDownloadInfo = [manager managedDownload:item.identifier];
    if (managedDownloadInfo != nil && NO)
    {
        // What state is it in?
        switch (managedDownloadInfo.downloadStatus)
        {
            case DownloadInfoStatusActive:
                // Need to grab the item, download it, then give it back/finalise it ourselves
                break;
            
            case DownloadInfoStatusDownloading:
                // Hook into current download
                break;
                
            case DownloadInfoStatusFailed:
                // Try again?
                break;
            
            default:
                break;
        }
    }
    else
    {
        DownloadInfo *downloadInfo = [[DownloadInfo alloc] initWithRepositoryItem:item withAcctUUID:anAccountUUID withRepositoryID:aRepositoryID withTenantID:nil];
        [self setCurrentDownload:downloadInfo];
        
        [self setDelegate:aDelegate];
        
        CMISDownloadFileRequest *request = [CMISDownloadFileRequest cmisDownloadRequestWithDownloadInfo:downloadInfo];
        [request setDelegate:self];
        [downloadInfo setDownloadStatus:DownloadInfoStatusActive];
        [downloadInfo setDownloadRequest:request];
        //[request setTotalBytesDownload:[[[[downloadInfo repositoryItem] metadata] objectForKey:@"cmis:contentStreamLength"] integerValue]];
    }
}

- (void)cancelPreview
{
    [self.currentDownload.downloadRequest clearDelegatesAndCancel];
    if ([self.delegate respondsToSelector:@selector(previewManager:downloadCancelled:)])
    {
        [self.delegate previewManager:self downloadCancelled:self.currentDownload];
    }
    
    [self setCurrentDownload:nil];
}

- (void)reconnectWithDelegate:(id<PreviewManagerDelegate>)aDelegate
{
    [self setDelegate:aDelegate];
    if ([self.delegate respondsToSelector:@selector(previewManager:downloadStarted:)])
    {
        [self.delegate previewManager:self downloadStarted:self.currentDownload];
    }
}

- (BOOL)isManagedPreview:(NSString *)cmisObjectId
{
    return [self.currentDownload.cmisObjectId isEqualToString:cmisObjectId];
}

// Progress notifications from the DownloadManager's downloads

- (void)downloadProgress:(float)newProgress forDownloadInfo:(DownloadInfo *)downloadInfo
{
    if ([downloadInfo.cmisObjectId isEqualToString:self.currentDownload.cmisObjectId])
    {
        if ([self.progressIndicator respondsToSelector:@selector(setProgress:)])
        {
            [self.progressIndicator setProgress:newProgress];
        }
    }
}

- (float)currentProgress
{
    float progressAmount = 0;
    if (self.currentDownload.downloadStatus == DownloadInfoStatusDownloading)
    {
        CMISDownloadFileRequest *request = self.currentDownload.downloadRequest;
        if (request.downloadedBytes + request.totalBytes > 0)
        {
            progressAmount = (request.downloadedBytes * 1.0) / (request.totalBytes * 1.0);
        }
    }

    return MIN(0, progressAmount);
}

#pragma mark - Progress Delegates

- (void)setProgressIndicator:(id)progressIndicator
{
    _progressIndicator = progressIndicator;
    
    [self.currentDownload.downloadRequest setDownloadProgressDelegate:progressIndicator];
}


#pragma mark - ASINetworkQueue Delegate

- (void)requestStarted:(CMISDownloadFileRequest *)request
{
    [self.currentDownload setDownloadStatus:DownloadInfoStatusDownloading];
    if ([self.delegate respondsToSelector:@selector(previewManager:downloadStarted:)])
    {
        [self.delegate previewManager:self downloadStarted:self.currentDownload];
    }
}

- (void)requestFinished:(CMISDownloadFileRequest *)request
{
    [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:request.downloadInfo.tempFilePath];
    [self.currentDownload setDownloadStatus:DownloadInfoStatusDownloaded];
    [self.currentDownload setTempFilePath:request.downloadInfo.tempFilePath];
    
    
    if ([self.delegate respondsToSelector:@selector(previewManager:downloadFinished:)])
    {
        [self.delegate previewManager:self downloadFinished:self.currentDownload];
    }
    
    DownloadInfo *downloadInfo = request.downloadInfo;
    [downloadInfo setDownloadRequest:nil];
    [self setCurrentDownload:nil];
    //[[PreviewCacheManager sharedManager] cachePreviewFile:downloadInfo];
}

- (void)requestFailed:(CMISDownloadFileRequest *)request
{
    [self.currentDownload setDownloadStatus:DownloadInfoStatusFailed];
    if ([self.delegate respondsToSelector:@selector(previewManager:downloadFailed:withError:)])
    {
        [self.delegate previewManager:self downloadFailed:self.currentDownload withError:request.error];
    }
    
    DownloadInfo *downloadInfo = request.downloadInfo;
    [downloadInfo setDownloadRequest:nil];
    [self setCurrentDownload:nil];
}

@end
