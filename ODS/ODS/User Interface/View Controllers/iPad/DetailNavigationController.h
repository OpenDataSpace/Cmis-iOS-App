//
//  DetailNavigationController.h
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailNavigationController : UINavigationController <UISplitViewControllerDelegate> {
    BOOL hideMasterAlways;
    BOOL previousExpandedState;
}

@property (nonatomic, strong, readonly) UIViewController *detailViewController;
@property (nonatomic, strong) UIBarButtonItem *masterPopoverBarButton;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, strong) UIViewController *fullScreenModalController;
@property (nonatomic, copy) NSString *popoverButtonTitle;

@property (nonatomic, strong) UIBarButtonItem *expandButton;
@property (nonatomic, strong) UIBarButtonItem *closeButton;

@property (nonatomic, assign) BOOL isExpanded;

- (void)resetViewControllerStackWithNewTopViewController:(UIViewController *)newTopViewController dismissPopover:(BOOL)dismissPopover;
- (void)addViewControllerToStack:(UIViewController *)newTopViewController;
- (void)dismissPopover;
- (void)showFullScreen;
- (void)showFullScreenOnTopWithCloseButtonTitle:(NSString *)closeButtonTitle;
- (void)showMasterPopoverController;
- (void)performCloseAction:(id)sender;
@end
