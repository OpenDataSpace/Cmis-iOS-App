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
//  MessageViewController.m
//

#import "MessageViewController.h"
#import "TTTAttributedLabel.h"

CGFloat const kMessageViewControllerPadding = 5.0f;
CGFloat const kMessageViewPopoverWidth = 220.0f;
CGFloat const kMessageViewPopoverHeigh = 400.0f;

@interface MessageViewController ()

@end

@implementation MessageViewController
@synthesize messageLabel = _messageLabel;

- (void)dealloc
{
    _messageLabel = nil;
}

- (id)initWithMessage:(NSString *)message
{
    self = [self initWithNibName:nil bundle:nil];
    if(self)
    {
        [self loadView];
        [self.messageLabel setText:message];
    }
    return self;
}

- (void)loadView
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMessageViewPopoverWidth, kMessageViewPopoverHeigh)];
    [paddingView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [paddingView setBackgroundColor:[UIColor whiteColor]];
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kMessageViewControllerPadding, kMessageViewControllerPadding, kMessageViewPopoverWidth - (kMessageViewControllerPadding*2), kMessageViewPopoverHeigh - (kMessageViewControllerPadding*2))];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setNumberOfLines:0];
    [label setTextAlignment:NSTextAlignmentLeft];
    [paddingView addSubview:label];
    [self setMessageLabel:label];
    [self setView:paddingView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (CGSize)contentSizeForViewInPopover
{
    CGSize contentSize = [self.messageLabel sizeThatFits:CGSizeMake(220, MAXFLOAT)];
    CGFloat totalPadding = kMessageViewControllerPadding * 2;
    contentSize = CGSizeMake(contentSize.width + totalPadding, contentSize.height + totalPadding);
    return contentSize; 
}

@end
