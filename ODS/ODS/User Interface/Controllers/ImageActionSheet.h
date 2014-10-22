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
//  ImageActionSheet.h
//
// Custom image action sheet that is able to add images to buttons in the actionsheet

#import <UIKit/UIKit.h>

@interface ImageActionSheet : UIActionSheet

@property (nonatomic, retain) NSMutableDictionary *images;

/*
    DI
 Inits an ImageActionSheet with a title, delegate, cancelButtonTitle, destructiveButtonTitle and a list of 
 titles and images (for the button icons) for other buttons.
 All parameters are optional.
 */
- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitlesAndImages:(NSString *)firstTitle, ... NS_REQUIRES_NIL_TERMINATION;

/*
 Adds a button with a title and an image to the left of the title
 */
- (NSInteger)addButtonWithTitle:(NSString *)title andImage:(UIImage *)image;

/*
 Adds an image to the left of the title of the button in the buttonIndex parameter
 */
- (void)addImage:(UIImage *)image toButtonIndex:(NSInteger)buttonIndex;
/*
 Adds an image to the left of the title of the button with the given title
 */
- (void)addImage:(UIImage *)image toButtonWithTitle:(NSString *)buttonTitle;

@end
