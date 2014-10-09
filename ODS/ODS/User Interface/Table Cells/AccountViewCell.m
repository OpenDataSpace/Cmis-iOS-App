//
//  AccountViewCell.m
//  ODS
//
//  Created by bdt on 8/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AccountViewCell.h"
#import "AccountInfo.h"

@implementation AccountViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setAccountInfo:(AccountInfo*) acctInfo {
    AccountStatus *acctStatus = [acctInfo accountStatusInfo];

    [self.imgIcon setImage:[UIImage imageNamed:kServerIcon_ImageName]];
    
    if ([acctStatus isActive]) {
        [self.lblActiveAccountName setText:acctInfo.vendor];
        [self.lblActiveAccountName setHidden:NO];
        [self.lblAccountName setHidden:YES];
        [self.lblAccountStatus setHidden:YES];
        [self.imgErrorIcon setHidden:![acctStatus isError]];
    }else {
        [self.lblAccountName setText:acctInfo.vendor];
        [self.lblActiveAccountName setHidden:YES];
        [self.lblAccountName setHidden:NO];
        [self.lblAccountStatus setHidden:NO];
        [self.imgErrorIcon setHidden:![acctStatus isError]];
        [self.lblAccountStatus setTextColor:[acctStatus shortMessageTextColor]];
        [self.lblAccountStatus setText:[acctStatus shortMessage]];
        if ([acctStatus isError]) {  //error icon
            [self.imgErrorIcon setImage:[UIImage imageNamed:kImageUIButtonBarBadgeError]];
        }
    }
}

@end
