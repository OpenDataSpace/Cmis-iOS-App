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
 *
 * ***** END LICENSE BLOCK ***** */

//
//  MultiSelectActionItem.m
//

#import "MultiSelectActionItem.h"

/**
 * Implementation
 */
@implementation MultiSelectActionItem

@synthesize name = _name;
@synthesize labelKey = _labelKey;
@synthesize labelKeyExt = _labelKeyExt;
@synthesize index = _index;
@synthesize isDestructive = _isDestructive;
@synthesize button = _button;

#pragma mark - Dealloc

- (void)dealloc
{
    [_name release];
    [_labelKey release];
    [_labelKeyExt release];
    [_button release];
    
    [super dealloc];
}

#pragma mark - Public instance methods

- (void)setLabelKey:(NSString *)value
{
    _labelKey = value;
    self.labelKeyExt = [NSString stringByAppendingString:@".counter" toString:_labelKey];
}

- (NSString *)labelWithCounterValue:(NSUInteger)counter
{
    NSString *labelValue;
    
    if (counter == 0)
    {
        labelValue = NSLocalizedString(self.labelKey, self.labelKey);
    }
    else
    {
        NSString *lbl = NSLocalizedString(self.labelKeyExt, self.labelKeyExt);
        labelValue = [NSString stringWithFormat:lbl, counter];
    }
    
    return labelValue;
}

- (void)setButtonTitleWithCounterValue:(NSUInteger)counter
{
    [self.button setTitle:[self labelWithCounterValue:counter]];
}

@end
