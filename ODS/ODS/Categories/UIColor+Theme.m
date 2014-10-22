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
//  UIColor+Theme.m
//

#import "UIColor+Theme.h"


@implementation UIColor (Theme)

+ (UIColor *)colorWithHexRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alphaTransparency:(CGFloat)alpha
{
	return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

+ (UIColor *)ziaThemeSandColor
{
	return [UIColor colorWithHexRed:204.0f green:192.0f blue:144.0f alphaTransparency:1.0f];
}

+ (UIColor *)panelBackgroundColor
{
    return [UIColor colorWithHexRed:51.0f green:51.0f blue:51.0f alphaTransparency:1.0f];
}

+ (UIColor *)selectedPanelBackgroundColor
{
    return [UIColor colorWithHexRed:81.0f green:81.0f blue:81.0f alphaTransparency:1.0f];
}

@end
