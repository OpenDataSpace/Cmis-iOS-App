//
//  DetailNavigationController.m
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DetailNavigationController.h"
#import <MediaPlayer/MPMoviePlayerController.h>

static CGFloat masterViewControllerWidth = 320.0;

@interface DetailNavigationController ()
@property (nonatomic, strong, readwrite) UIViewController *detailViewController;
- (void)configureView;
@end

@implementation DetailNavigationController
@synthesize fullScreenModalController = _fullScreenModalController;
@synthesize popoverButtonTitle = _popoverButtonTitle;
@synthesize masterPopoverBarButton = _masterPopoverBarButton;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize expandButton = _expandButton;
@synthesize closeButton = _closeButton;
@synthesize splitViewController = _splitViewController;
@synthesize isExpanded = _isExpanded;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _detailViewController = nil;
    _fullScreenModalController = nil;
    _popoverButtonTitle = nil;
    _masterPopoverBarButton = nil;
    _masterPopoverController = nil;
    _expandButton = nil;
    _closeButton = nil;
    _splitViewController = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Detail", @"Detail");
    
    self.expandButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"expand"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self action:@selector(performAction:)];
    
    self.closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close")
                                                         style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(performCloseAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBrowseDocuments:) name:kBrowseDocumentsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    self.navigationBar.translucent = NO;
    
    //configure view
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self.detailViewController = rootViewController;
    return [super initWithRootViewController:rootViewController];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailViewController)
    {
        ODSLogDebug(@"Detail View Controller title: %@", self.detailViewController.title);
        
        if (self.fullScreenModalController)
        {
            [self setViewControllers:[NSArray arrayWithObjects:self.detailViewController, self.fullScreenModalController, nil]];
        }
        else
        {
            [self setViewControllers:[NSArray arrayWithObject:self.detailViewController]];
        }
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            [self.detailViewController.navigationItem setLeftBarButtonItem:self.expandButton animated:NO];
        }
        else
        {
            [self.detailViewController.navigationItem setLeftBarButtonItem:self.masterPopoverBarButton animated:NO];
        }
    }
}

#pragma mark - Managing the detail item

- (void)resetViewControllerStackWithNewTopViewController:(UIViewController *)newTopViewController dismissPopover:(BOOL)dismissPopover
{
    if (self.detailViewController != newTopViewController)
    {
        [self setViewControllers:nil animated:NO];
        [self setDetailViewController:newTopViewController];
        
        // Update the view.
        [self configureView];
    }
    
    if (dismissPopover)
    {
        [self dismissPopover];
    }
}

- (void)addViewControllerToStack:(UIViewController *)newTopViewController
{
    [self setViewControllers:nil animated:NO];
    [self setFullScreenModalController:newTopViewController];
    
    [self configureView];
    
    [self dismissPopover];
}

- (void)dismissPopover
{
    if (self.masterPopoverController && self.masterPopoverController.popoverVisible)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"popover.button.title", @"ODS");
    UIViewController *current = [self.viewControllers objectAtIndex:0];
    [current.navigationItem setLeftBarButtonItem:barButtonItem animated:NO];
    
    self.masterPopoverBarButton = barButtonItem;
    self.masterPopoverController = popoverController;
    self.splitViewController = splitController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.expandButton setImage:[UIImage imageNamed:@"expand"]];
    
    UIViewController *current = [self.viewControllers objectAtIndex:0];
    [current.navigationItem setLeftBarButtonItem:self.expandButton animated:NO];
    
    self.masterPopoverController = nil;
    self.isExpanded = NO;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return (UIInterfaceOrientationIsPortrait(orientation) || hideMasterAlways);
}

- (void)performAction:(id)sender
{
    [self expandDetailView:!self.isExpanded animated:YES];
}

- (void)expandDetailView:(BOOL)expanded animated:(BOOL)animated
{
    if (expanded == self.isExpanded || UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        return;
    }
    
    UIViewController *masterViewController = [self.splitViewController.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
    
    CGRect splitFrame = self.splitViewController.view.frame;
    CGRect masterFrame = masterViewController.view.frame;
    CGRect detailFrame = detailViewController.view.frame;
    
    CGFloat delta = self.isExpanded ? -masterViewControllerWidth : masterViewControllerWidth;
    
    if (IOS8_OR_LATER) {
        if (expanded) {
            _splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
        }else {
            _splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
        }
    }else {
        if (self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
        {
            splitFrame.origin.y -= delta;
        }
        splitFrame.size.height += delta;
        masterFrame.origin.x -= delta;
        detailFrame.size.width += delta;
    }    
    
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
    }
    self.splitViewController.view.frame = splitFrame;
    masterViewController.view.frame = masterFrame;
    detailViewController.view.frame = detailFrame;
    
    
    if (animated)
    {
        [UIView commitAnimations];
    }
   
    self.isExpanded = !self.isExpanded;
    
    UIViewController *current = [self.viewControllers objectAtIndex:0];
    [current.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:(self.isExpanded ? @"collapse" : @"expand")]];
}

- (void)showFullScreen {
    [self expandDetailView:YES animated:NO];
}

// Shows the view controller on top of an existing view controller
- (void)showFullScreenOnTopWithCloseButtonTitle:(NSString *)closeButtonTitle
{
    self.closeButton.title = closeButtonTitle;
    
    UIViewController *current = [self.viewControllers objectAtIndex:1];
    [current.navigationItem setLeftBarButtonItem:self.closeButton];
    
    previousExpandedState = self.isExpanded;
    [self expandDetailView:YES animated:NO];
    hideMasterAlways = YES;
}

- (void)performCloseAction:(id)sender
{
    self.fullScreenModalController = nil;
    [self configureView];
    
    // restore defaults
    [self expandDetailView:previousExpandedState animated:NO];
    hideMasterAlways = NO;
}

- (void)showMasterPopoverController
{
    @try {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && self.masterPopoverController && self.masterPopoverBarButton)
        {
            [self.masterPopoverBarButton.target performSelector:self.masterPopoverBarButton.action];
        }
    }
    @catch (NSException *exception) {
        ODSLogDebug(@"exception:%@", exception);
    }
    @finally {
        
    }
}

#pragma mark - NotificationCenter methods

- (void)handleBrowseDocuments:(NSNotification *)notification
{
    [IpadSupport clearDetailController];
    [self showMasterPopoverController];
}

#pragma mark - Movie Player Notifications

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    if (IS_IPAD && self.isExpanded)
    {
        // UISplitViewController resets the frame split after a the moviePlayerViewController dismisses - we'll need to reset it
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationDidStopNotification:) name:@"UIViewAnimationDidStopNotification" object:nil];
    }
}

- (void)animationDidStopNotification:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:@"name"] isEqualToString:@"Modal Transition"])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIViewAnimationDidStopNotification" object:nil];
        self.isExpanded = NO;
        [self expandDetailView:YES animated:NO];
    }
}
@end
