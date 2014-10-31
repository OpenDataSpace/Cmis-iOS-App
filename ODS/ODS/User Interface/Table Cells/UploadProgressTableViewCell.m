//
//  UploadProgressTableViewCell.m
//  ODS
//
//  Created by bdt on 10/10/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadProgressTableViewCell.h"
#import "CMISUploadRequest.h"
#import "UIColor+Theme.h"

@implementation UploadProgressTableViewCell
@synthesize uploadInfo = _uploadInfo;

- (void) dealloc {
    if (self.uploadInfo) {
        if (self.uploadInfo.uploadRequest) {
            [self.uploadInfo.uploadRequest setUploadProgressDelegate:nil];
        }
    }
}

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadChanged:) name:kNotificationUploadWaiting object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadChanged:) name:kNotificationUploadStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadChanged:) name:kNotificationUploadFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadChanged:) name:kNotificationUploadFailed object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Utility methods
- (void) waitingForUploadState {
    [self.labelUploadStatus setTextColor:[UIColor colorWithHexRed:110 green:110 blue:110 alphaTransparency:1]];
    [self.labelFileName setTextColor:[UIColor blackColor]];
    [self.labelUploadStatus setHidden:NO];
    [self.progressView setHidden:YES];
    
    [self.labelUploadStatus setText:NSLocalizedString(@"Waiting to upload...", @"")];
    //[self setAccessoryView:[self makeCloseDisclosureButton]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setNeedsLayout];
    [self setNeedsDisplay];

}

- (void) finishedForUploadState {
    [self.labelUploadStatus setTextColor:[UIColor colorWithHexRed:110 green:110 blue:110 alphaTransparency:1]];
    [self.labelFileName setTextColor:[UIColor blackColor]];
    [self.labelUploadStatus setHidden:NO];
    [self.progressView setHidden:YES];
    
    [self.labelUploadStatus setText:NSLocalizedString(@"upload.finished", @"")];
    //[self setAccessoryView:[self makeCloseDisclosureButton]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void) enableProgressView {
    [self.uploadInfo.uploadRequest setUploadProgressDelegate:self.progressView];
    [self.labelUploadStatus setTextColor:[UIColor colorWithHexRed:110 green:110 blue:110 alphaTransparency:1]];
    [self.labelFileName setTextColor:[UIColor blackColor]];
    [self.labelUploadStatus setHidden:YES];
    [self.progressView setHidden:NO];
    [self.progressView setProgress:0];
    
    //[self setAccessoryView:[self makeCloseDisclosureButton]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)failedUploadState
{
    [self.labelUploadStatus setHidden:NO];
    [self.progressView setHidden:YES];
    
    [self.labelUploadStatus setTextColor:[UIColor redColor]];
    [self.labelFileName setTextColor:[UIColor lightGrayColor]];
    
    //[self setAccessoryView:[self makeFailureDisclosureButton]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.labelUploadStatus setText:NSLocalizedString(@"Failed to Upload", @"")];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setUploadInfo:(UploadInfo *)uploadInfo
{
    if (_uploadInfo.uploadRequest) {
        [_uploadInfo.uploadRequest setUploadProgressDelegate:nil];
    }
    _uploadInfo = uploadInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.labelFileName setText:[uploadInfo completeFileName]];
        [self.imgFileIcon setImage:imageForFilename([uploadInfo completeFileName])];
        
        switch (_uploadInfo.uploadStatus)
        {
            case UploadInfoStatusActive:
                [self waitingForUploadState];
                break;
            case UploadInfoStatusUploading:
                [self enableProgressView];
                break;
            case UploadInfoStatusFailed:
                [self failedUploadState];
                break;
            case UploadInfoStatusUploaded:
                [self finishedForUploadState];
                break;
            default:
                [self waitingForUploadState];
                break;
        }
    });
}

#pragma mark - Notification methods
- (void)uploadChanged:(NSNotification *)notification
{
    UploadInfo *uploadInfo = [notification.userInfo objectForKey:@"uploadInfo"];
    if (uploadInfo.uuid == self.uploadInfo.uuid)
    {
        [self setUploadInfo:uploadInfo];
    }
}
@end
