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
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  FailedTransferDetailViewController.m
//

#import "FailedTransferDetailViewController.h"

const CGFloat kFailedTransferDetailPadding = 10.0f;
const CGFloat kFailedTransferDetailHeight = 400.;
const CGFloat kFailedTransferDetailWidth = 272.;

@interface FailedTransferDetailViewController ()
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *messageText;
@end

@implementation FailedTransferDetailViewController

@synthesize userInfo = _userInfo;
@synthesize titleText = _titleText;
@synthesize messageText = _messageText;
@synthesize closeAction = _closeAction;
@synthesize closeTarget = _closeTarget;

- (void)dealloc
{
    _userInfo = nil;
    _titleText = nil;
    _messageText = nil;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    self = [super init];
    if (self)
    {
        [self setTitleText:title];
        [self setMessageText:message];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFailedTransferDetailWidth, kFailedTransferDetailHeight)];
    [containerView setBackgroundColor:[UIColor clearColor]];
    UIImage *backgroundTemplate = [UIImage imageNamed:@"failed-transfer-detail-background"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[backgroundTemplate resizableImageWithCapInsets:UIEdgeInsetsMake(30., 0., 48., kFailedTransferDetailWidth)]];
    [backgroundImageView setFrame:containerView.frame];
    [containerView addSubview:backgroundImageView];
    
    CGFloat subViewWidth = kFailedTransferDetailWidth - (kFailedTransferDetailPadding * 2);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFailedTransferDetailPadding, kFailedTransferDetailPadding, subViewWidth, 0)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:19.]];
    [titleLabel setText:self.titleText];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setShadowColor:[UIColor blackColor]];
    CGRect titleFrame = titleLabel.frame;
    titleFrame.size.height = [titleLabel sizeThatFits:CGSizeMake(subViewWidth, kFailedTransferDetailHeight)].height;
    [titleLabel setFrame:titleFrame];
    [containerView addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFailedTransferDetailPadding, titleFrame.size.height + (kFailedTransferDetailPadding * 2), subViewWidth, 0)];
    [descriptionLabel setFont:[UIFont systemFontOfSize:17.]];
    [descriptionLabel setNumberOfLines:0];
    [descriptionLabel setText:self.messageText];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [descriptionLabel setTextColor:[UIColor whiteColor]];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel setShadowColor:[UIColor blackColor]];
    CGRect descriptionFrame = descriptionLabel.frame;
    descriptionFrame.size.height = [descriptionLabel sizeThatFits:CGSizeMake(subViewWidth, kFailedTransferDetailHeight)].height;
    [descriptionLabel setFrame:descriptionFrame];
    [containerView addSubview:descriptionLabel];
    
    UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [retryButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.]];
    [retryButton setTitle:NSLocalizedString(@"Retry", @"Retry") forState:UIControlStateNormal];
    [retryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage *buttonTemplate = [UIImage imageNamed:@"failed-transfer-detail-button"];
    UIImage *stretchedButtonImage = [buttonTemplate resizableImageWithCapInsets:UIEdgeInsetsMake(7., 5., 37., 5.)];
    [retryButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    
    CGRect retryButtonFrame = CGRectMake(kFailedTransferDetailPadding, titleFrame.size.height + descriptionFrame.size.height + (kFailedTransferDetailPadding * 3), subViewWidth, 40);
    [retryButton setFrame:retryButtonFrame];
    [retryButton addTarget:self action:@selector(retryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:retryButton];
    
    CGRect containerFrame = containerView.frame;
    containerFrame.size.height = titleLabel.frame.size.height + descriptionLabel.frame.size.height + retryButton.frame.size.height + (kFailedTransferDetailPadding * 4); 
    [containerView setFrame:containerFrame];
    [self setView:containerView];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Button Action

- (void)retryButtonAction:(id)sender
{
    if (self.closeTarget && [self.closeTarget respondsToSelector:self.closeAction])
    {
        [self.closeTarget performSelector:self.closeAction withObject:self];
    }
}

@end
