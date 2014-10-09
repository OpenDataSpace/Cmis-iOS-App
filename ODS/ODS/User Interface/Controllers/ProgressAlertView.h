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
//  ProgressAlertView.h
//
// Progress alert view that can be used as an UI to signal the user an app process is running
// The difference between using this rather than a MBProgressHUD directly is that we don't need to worry for the
// parent view since the MBProgressHUD will be displayed inside an UIAlertView.

#import <Foundation/Foundation.h>
@class MBProgressHUD;

@interface ProgressAlertView : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) NSTimeInterval minTime;

/*
 Initializes a ProgressAlertView object and sets the waiting message with the provided parameter
 */
- (id)initWithMessage:(NSString *)message;
/*
 It shows the UIAlertView in the screen and starts the HUD animation
 */
- (void)show;
/*
 It dismisses the UIAlertView and stops the HUD animation
 */
- (void)hide;
@end
