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
//  MultiSelectActionItem.h
//

#import <Foundation/Foundation.h>

@interface MultiSelectActionItem : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *labelKey;
@property (nonatomic, retain) NSString *labelKeyExt;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL isDestructive;
@property (nonatomic, retain) UIBarButtonItem *button;

- (NSString *)labelWithCounterValue:(NSUInteger)counter;
- (void)setButtonTitleWithCounterValue:(NSUInteger)counter;

@end
