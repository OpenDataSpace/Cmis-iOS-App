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
//  ToggleBarButtonItemDecorator.m
//

#import "ToggleBarButtonItemDecorator.h"

@implementation ToggleBarButtonItemDecorator


- (void) dealloc
{
    _toggleOnImage = nil;
    _toggleOffImage = nil;
    _barButton = nil;
}

- (ToggleBarButtonItemDecorator *)initWithOffImage:(UIImage *)newToggleOffImage
                                           onImage:(UIImage *)newToggleOn
                                             style:(UIBarButtonItemStyle)style
                                            target:(id)target
                                            action:(SEL)action
{
    self = [super init];
    if (self)
    {
        self.barButton = [[UIBarButtonItem alloc] initWithImage:newToggleOffImage style:style target:self action:@selector(toggleAndContinue:)];
        self.toggleOnImage = newToggleOn;
        self.toggleOffImage = newToggleOffImage;
        self.action = action;
        self.target = target;
        self.toggleState = NO;
    }
    
    return self;
}

- (void)toggleImage
{
    if (self.toggleState)
    {
        self.toggleState = NO;
        self.barButton.image = self.toggleOffImage;
    }
    else
    {
        self.toggleState = YES;
        self.barButton.image = self.toggleOnImage;
    }
}

- (void)toggleAndContinue:(id)sender
{
	[self toggleImage];
    
    if ([self.target respondsToSelector:self.action])
    {
        [self.target performSelector:self.action withObject:sender];
    }
}

@end
