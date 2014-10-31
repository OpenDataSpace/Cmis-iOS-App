//
//  DownloadFailureSummaryTableViewCell.h
//  ODS
//
//  Created by bdt on 10/13/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKNumberBadgeView;

extern NSString * const kDownloadFailureSummaryCellIdentifier;

@interface DownloadFailureSummaryTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet MKNumberBadgeView *badgeView;
@end
