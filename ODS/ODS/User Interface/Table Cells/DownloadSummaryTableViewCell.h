//
//  DownloadSummaryTableViewCell.h
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView.h"

extern NSString * const kDownloadSummaryCellIdentifier;

@interface DownloadSummaryTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelProgress;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;
@property (nonatomic, weak) IBOutlet MKNumberBadgeView *downloadsBadge;
@end
