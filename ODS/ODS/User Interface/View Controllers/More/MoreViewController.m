//
//  MoreViewController.m
//  ODS
//
//  Created by bdt on 9/21/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "MoreViewController.h"

#import "MoreTableViewCell.h"
#import "UploadsManager.h"
#import "ManageAccountsViewController.h"
#import "AboutViewController.h"
#import "UploadsViewController.h"

static NSString * const kModelManageAccountsIdentifier = @"ModelManageAccountsIdentifier";
static NSString * const kModelManageUploadsIdentifier = @"ModelManageUploadsIdentifier";
static NSString * const kModelAboutIdentifier = @"ModelAboutIdentifier";

@interface MoreViewController ()
@property (nonatomic, strong) NSMutableArray    *itemsOfMore;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem setTitle:NSLocalizedString(@"more.view.title", @"More")];
    [self createItemsOfMore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.itemsOfMore) {
        return [self.itemsOfMore count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.itemsOfMore objectAtIndex:indexPath.row];;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreTableViewCell *cellSelected = [self.itemsOfMore objectAtIndex:indexPath.row];
    
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
    if (self.itemsOfMore == nil) {
        self.itemsOfMore = [NSMutableArray array];
        
        MoreTableViewCell *cell = (MoreTableViewCell*)[self createTableViewCellFromNib:@"MoreTableViewCell"];
        
        //account manager cell
        [cell.labelTitle setText:NSLocalizedString(@"more.item.account", @"Manage Accounts")];
        [cell.cellIcon setImage:[UIImage imageNamed:@"accounts-more"]];
        [cell setModelIdentifier:kModelManageAccountsIdentifier];
        [self.itemsOfMore addObject:cell];
        
        //uploads cell
        if ([[UploadsManager sharedManager] allUploads] > 0) {
            cell = (MoreTableViewCell*)[self createTableViewCellFromNib:@"MoreTableViewCell"];
            [cell.labelTitle setText:NSLocalizedString(@"more.item.upload", @"Manage Accounts")];
            [cell.cellIcon setImage:[UIImage imageNamed:@"cloud"]];
            [cell setModelIdentifier:kModelManageUploadsIdentifier];
            [self.itemsOfMore addObject:cell];
        }
        
        //about cell
        cell = (MoreTableViewCell*)[self createTableViewCellFromNib:@"MoreTableViewCell"];
        [cell.labelTitle setText:NSLocalizedString(@"more.item.about", @"Manage Accounts")];
        [cell.cellIcon setImage:[UIImage imageNamed:@"about-more"]];
        [cell setModelIdentifier:kModelAboutIdentifier];
        [self.itemsOfMore addObject:cell];
        
    }
}

@end
