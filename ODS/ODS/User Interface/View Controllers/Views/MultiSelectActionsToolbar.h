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
//  MultiSelectActionsToolbar.h
//

#import <UIKit/UIKit.h>

@class MultiSelectActionsToolbar;

/**
 * MultiSelectActionsDelegate
 */
@protocol MultiSelectActionsDelegate
@optional
- (void)multiSelectItemsDidChange:(MultiSelectActionsToolbar *)msaToolbar items:(NSArray *)selectedItems;
- (void)multiSelectUserDidPerformAction:(MultiSelectActionsToolbar *)msaToolbar named:(NSString *)name withItems:(NSArray *)selectedItems atIndexPaths:(NSArray *)selectedIndexPaths;
@end

/**
 * MultiSelectActionsToolbar
 */
@interface MultiSelectActionsToolbar : UIToolbar

@property (nonatomic, assign) id <MultiSelectActionsDelegate> multiSelectDelegate;

- (id)initWithParentViewController:(UIViewController *)viewController;

- (void)didEnterMultiSelectMode;
- (void)didEnterMultiSelectModeFromSearchView:(BOOL)searchViewIsActive;
- (void)didLeaveMultiSelectMode;

- (void)addActionButtonNamed:(NSString *)name withLabelKey:(NSString *)labelKey atIndex:(NSUInteger)index;
- (void)addActionButtonNamed:(NSString *)name withLabelKey:(NSString *)labelKey atIndex:(NSUInteger)index isDestructive:(BOOL)destructiveAction;
- (void)enableActionButtonNamed:(NSString *)name isEnabled:(BOOL)enabled;

- (void)userDidSelectItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
- (void)userDidDeselectItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
- (void)removeAllSelectedItems;

@end
