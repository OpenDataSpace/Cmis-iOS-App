//
//  DownloadFailureSummaryTableViewCell.m
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadFailureSummaryTableViewCell.h"
#import "DownloadManager.h"
#import "MKNumberBadgeView.h"

NSString * const kDownloadFailureSummaryCellIdentifier = @"DownloadFailureSummaryCellIdentifier";

@implementation DownloadFailureSummaryTableViewCell
@synthesize titleLabel = _titleLabel;
@synthesize badgeView = _badgeView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _titleLabel = nil;
    _badgeView = nil;
}

- (void)awakeFromNib {
    // Initialization code
    [_titleLabel setText:NSLocalizedString(@"download.failures.title", @"Failures")];
    [_badgeView setValue:[[[DownloadManager sharedManager] failedDownloads] count]];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadQueueChanged:) name:kNotificationDownloadQueueChanged object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)shouldIndentWhileEditing
{
    return NO;
}

#pragma mark - Download notifications

- (void)downloadQueueChanged:(NSNotification *)notification
{
    [self.badgeView setValue:[[[DownloadManager sharedManager] failedDownloads] count]];
}

@end
