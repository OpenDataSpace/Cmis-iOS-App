//
//  MoreViewController.m
//  ODS
//
//  Created by bdt on 9/21/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "MoreViewController.h"

#import "MoreTableViewCell.h"
#import "UploadsManager.h"
#import "ManageAccountsViewController.h"
#import "AboutViewController.h"
#import "UploadsViewController.h"
#import "LogoManager.h"
#import "AccountManager.h"

static NSString * const kModelManageAccountsIdentifier = @"ModelManageAccountsIdentifier";
static NSString * const kModelManageUploadsIdentifier = @"ModelManageUploadsIdentifier";
static NSString * const kModelAboutIdentifier = @"ModelAboutIdentifier";

@interface MoreViewController ()
@end

@implementation MoreViewController
- (void) awakeFromNib {
    //set notification for update logo
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:kNotificationUpdateLogos object:nil];
    //upload notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadQueueChanged:) name:kNotificationUploadQueueChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccountListUpdated:) name:kNotificationAccountListUpdated object:nil];
    
    [self updateTabItemBadge];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem setTitle:NSLocalizedString(@"more.view.title", @"More")];
    [self createItemsOfMore];
    [self updateTabItemBadge];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableSections) {
        return [[self.tableSections objectAtIndex:section] count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *moreItems = [self.tableSections objectAtIndex:indexPath.section];
    return [moreItems objectAtIndex:indexPath.row];;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *moreItems = [self.tableSections objectAtIndex:indexPath.section];
    MoreTableViewCell *cellSelected = [moreItems objectAtIndex:indexPath.row];
    
    if ([[cellSelected modelIdentifier] isEqualToCaseInsensitiveString:kModelManageAccountsIdentifier]) { //Manage Accounts
        ManageAccountsViewController *manageAccountsController = [[ManageAccountsViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:manageAccountsController animated:YES];
    }else if ([[cellSelected modelIdentifier] isEqualToCaseInsensitiveString:kModelAboutIdentifier]) { //About view
        AboutViewController *aboutController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewControllerIdentifier"];
        //[self.navigationController pushViewController:aboutController animated:YES];
        [IpadSupport pushDetailController:aboutController withNavigation:self.navigationController andSender:self];
    }else if ([[cellSelected modelIdentifier] isEqualToCaseInsensitiveString:kModelManageUploadsIdentifier]) { //Manage Uploads
        UploadsViewController *uploadsController = [[UploadsViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:uploadsController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL) enableRefreshController {
    return NO;
}

- (void) createItemsOfMore {
    if (self.tableSections == nil) {
        self.tableSections = [NSMutableArray array];
        NSMutableArray *moreItems = [NSMutableArray array];
        
        MoreTableViewCell *cell = (MoreTableViewCell*)[self createTableViewCellFromNib:@"MoreTableViewCell"];
        
        //account manager cell
        [cell.labelTitle setText:NSLocalizedString(@"more.item.account", @"Manage Accounts")];
        [cell.cellIcon setImage:[UIImage imageNamed:@"accounts-more"]];
        [cell setModelIdentifier:kModelManageAccountsIdentifier];
        [moreItems addObject:cell];
        
        //uploads cell
        if ([[UploadsManager sharedManager] allUploads] > 0) {
            cell = (MoreTableViewCell*)[self createTableViewCellFromNib:@"MoreTableViewCell"];
            [cell.labelTitle setText:NSLocalizedString(@"more.item.upload", @"Manage Accounts")];
            [cell.cellIcon setImage:[UIImage imageNamed:@"manage_uploads"]];
            [cell setModelIdentifier:kModelManageUploadsIdentifier];
            [moreItems addObject:cell];
        }
        
        //about cell
        cell = (MoreTableViewCell*)[self createTableViewCellFromNib:@"MoreTableViewCell"];
        [cell.labelTitle setText:NSLocalizedString(@"more.item.about", @"Manage Accounts")];
        //[cell.cellIcon setImage:[UIImage imageNamed:@"about-more"]];
        [cell.cellIcon setImageWithURL:[[LogoManager shareManager] getLogoURLByName:KLogoAboutMore] placeholderImage:[UIImage imageNamed:KLogoAboutMore]];
        [cell setModelIdentifier:kModelAboutIdentifier];
        [moreItems addObject:cell];
        
        [self.tableSections addObject:moreItems];
    }
}

#pragma mark -
#pragma mark Handle Notification

- (void) handleNotification:(NSNotification*) noti {
    if ([noti.name isEqualToString:kNotificationUpdateLogos]) {
        MoreTableViewCell *aboutCell = (MoreTableViewCell*)[self findeCellByModeIdentifier:kModelAboutIdentifier];
        if (aboutCell) {
            [aboutCell.cellIcon setImageWithURL:[[LogoManager shareManager] getLogoURLByName:KLogoAboutMore] placeholderImage:[UIImage imageNamed:KLogoAboutMore]];
        }
    }
}

- (void)updateTabItemBadge
{
    NSArray *errorAccounts = [[AccountManager sharedManager] errorAccounts];
    NSArray *failedUploads = [[UploadsManager sharedManager] failedUploads];
    NSInteger activeCount = [[[UploadsManager sharedManager] activeUploads] count];
    MoreTableViewCell *manageAccountsCell = (MoreTableViewCell*)[self findeCellByModeIdentifier:kModelManageAccountsIdentifier];
    MoreTableViewCell *manageUploadsCell = (MoreTableViewCell*)[self findeCellByModeIdentifier:kModelManageUploadsIdentifier];
    if([failedUploads count] > 0 || [errorAccounts count] > 0)
    {
        [[self.navigationController tabBarItem]  setBadgeValue:@"!"];
        if ([errorAccounts count] > 0 &&  manageAccountsCell) {
            [manageAccountsCell.statusIcon setImage:[UIImage imageNamed:kImageUIButtonBarBadgeError]];
        }
        
        if ([failedUploads count] > 0 && manageUploadsCell) {
            [manageUploadsCell.statusIcon setImage:[UIImage imageNamed:kImageUIButtonBarBadgeError]];
        }
    }
    else if (activeCount > 0)
    {
        [[self.navigationController tabBarItem]  setBadgeValue:[NSString stringWithFormat:@"%d", activeCount]];
    }
    else
    {
        [[self.navigationController tabBarItem]  setBadgeValue:nil];
        [manageAccountsCell.statusIcon setImage:nil];
        [manageUploadsCell.statusIcon setImage:nil];
    }
}

- (void)handleAccountListUpdated:(NSNotification *)notification
{
    [self updateTabItemBadge];
}

- (void)uploadQueueChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTabItemBadge];
    });
}
@end
