//
//  RepositoryViewCell.h
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kRepositoryCellIdentifier;

@interface RepositoryViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView    *imgIcon;
@property (nonatomic, weak) IBOutlet UILabel        *lblRepositoryName;
@end
