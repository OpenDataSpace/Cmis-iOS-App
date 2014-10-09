//
//  AccountViewCell.h
//  ODS
//
//  Created by bdt on 8/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountInfo;
@interface AccountViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView    *imgIcon;
@property (nonatomic, weak) IBOutlet UIImageView    *imgErrorIcon;
@property (nonatomic, weak) IBOutlet UILabel        *lblAccountName;
@property (nonatomic, weak) IBOutlet UILabel        *lblAccountStatus;
@property (nonatomic, weak) IBOutlet UILabel        *lblActiveAccountName;

- (void) setAccountInfo:(AccountInfo*) acctInfo;
@end
