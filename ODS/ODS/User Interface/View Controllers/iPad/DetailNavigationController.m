//
//  DetailNavigationController.m
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DetailNavigationController.h"

@interface DetailNavigationController ()
@property (nonatomic, strong, readwrite) UIViewController *detailViewController;
@end

@implementation DetailNavigationController

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
    
    UIViewController *current = [self.viewControllers objectAtIndex:0];
    [current.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:(self.isExpanded ? @"collapse" : @"expand")]];
}

- (void)showFullScreen {
    
}
@end
