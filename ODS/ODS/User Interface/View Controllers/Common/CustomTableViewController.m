//
//  CustomTableViewController.m
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewController.h"

#define DEFAULT_TABLE_CELL_HEIGHT   62.0f

@interface CustomTableViewController ()
@end

@implementation CustomTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([self enableRefreshController]) {
        // Initialize Refresh Control
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        
        // Configure Refresh Control
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        
        // Configure View Controller
        [self setRefreshControl:refreshControl];
        
        //endfresh
        [self endRefreshing];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
#endif
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DEFAULT_TABLE_CELL_HEIGHT;
}

- (UITableViewCell*) createTableViewCellFromNib:(NSString*) nibName {
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    return [nibItems objectAtIndex:0];
}

- (CustomTableViewCell*) findeCellByModeIdentifier:(NSString*) modelIdentifier {
    if (self.tableSections != nil) {
        for (NSArray *section in self.tableSections) {
            for (CustomTableViewCell* cell in section) {
                if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:modelIdentifier]) {
                    return cell;
                }
            }
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark UIRefreshControl Handler
- (void)refresh:(id)sender {
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Loading...", @"Loading...")];
    }
}

- (void) endRefreshing {
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh...")];
    [self.tableView reloadData];
}

- (BOOL) enableRefreshController {
    return YES;
}

#pragma mark - MBProgressHUD Helper Methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [self stopHUD];
}

- (void)startHUD
{
	if (!self.HUD)
    {
        self.HUD = createAndShowProgressHUDForView([[self navigationController] view]);
        [self.HUD setDelegate:self];
	}
}

- (void)stopHUD
{
	if (self.HUD)
    {
        stopProgressHUD(self.HUD);
        self.HUD = nil;
    }
}

- (void)clearAllHUDs
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        for (UIView *view in [self.navigationController.view subviews])
        {
            if ([view class] == [MBProgressHUD class])
            {
                stopProgressHUD((MBProgressHUD*)view);
            }
        }
		self.HUD = nil;
    });
}

@end
