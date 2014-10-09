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
//  ProgressAlertView.m
//

#import "ProgressAlertView.h"
#import "MBProgressHUD.h"

@interface ProgressAlertView ()
@property (nonatomic, strong) NSDate *showTime;

- (void)dismissAlert;
@end

@implementation ProgressAlertView
@synthesize message = _message;
@synthesize alertView = _alertView;
@synthesize hud = _hud;
@synthesize minTime = _minTime;
@synthesize showTime = _showTime;

- (void)dealloc
{
    _message = nil;
    _alertView = nil;
    _hud = nil;
    _showTime = nil;
}

- (id)initWithMessage:(NSString *)message
{
    self = [super init];
    if(self)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@\n\n", message] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];

        MBProgressHUD *tmpHud = [[MBProgressHUD alloc] initWithView:alertView];
        [alertView addSubview:tmpHud];
        
        // Move the hud down a little to make room for two lines of text
        [tmpHud setYOffset:20.0f];
        
        [tmpHud setRemoveFromSuperViewOnHide:YES];
        [tmpHud setTaskInProgress:YES];
        [tmpHud setMinShowTime:kHUDMinShowTime];
        
        [self setMinTime:kHUDMinShowTime];
        [self setHud:tmpHud];
        [self setAlertView:alertView];
    }
    return self;
}

- (void)show
{
    [self setShowTime:[NSDate date]];
    [_hud show:YES];
    [_alertView show];
}

- (void)hide
{
    NSTimeInterval timeShowed = [_showTime timeIntervalSinceNow];
    // timeShowed will always be a negative interval if show was called before hide
    NSTimeInterval timeLeft = _minTime + timeShowed;
    
    if(timeLeft > 0)
    {
        [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:timeLeft];
    }
    else
    {
        [self dismissAlert];
    }
    [self setShowTime:nil];
}
       
- (void)dismissAlert
{
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [_hud show:NO];
}

@end
