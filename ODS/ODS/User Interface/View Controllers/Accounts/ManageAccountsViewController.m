//
//  ManageAccountsViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ManageAccountsViewController.h"
#import "AccountManager.h"
#import "AccountViewCell.h"
#import "AccountViewController.h"
#import "AccountStatusViewController.h"

static NSString * const kManageAccountsCellIdentifier = @"ManageAccountsCellIdentifier";

@interface ManageAccountsViewController ()

@end

@implementation ManageAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationItem] setTitle:NSLocalizedString(@"manage.accounts.view.title", @"Manage Accounts")];
    
 
    UIBarButtonItem *addBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(processAddButtonAction:)];
    [self.navigationItem setRightBarButtonItem:addBarItem];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountViewCell" bundle:nil] forCellReuseIdentifier:kManageAccountsCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNoAccountsCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccountListUpdated:)
                                                 name:kNotificationAccountListUpdated object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) enableRefreshController {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[AccountManager sharedManager] allAccounts] count] > 0?[[[AccountManager sharedManager] allAccounts] count]:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    if ([[[AccountManager sharedManager] allAccounts] count] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNoAccountsCellIdentifier forIndexPath:indexPath];
      
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNoAccountsCellIdentifier];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setText:NSLocalizedString(@"serverlist.cell.noaccounts", @"No Accounts")];
        
        return cell;
    }else {
        AccountViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kManageAccountsCellIdentifier forIndexPath:indexPath];
        AccountInfo *acctInfo = [[[AccountManager sharedManager] allAccounts] objectAtIndex:[indexPath row]];
        if (acctInfo) {
            [cell setAccountInfo:acctInfo];
        }
        
        return cell;
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[AccountManager sharedManager] allAccounts] count] > 0) {
        AccountInfo *acctInfo = [[[AccountManager sharedManager] allAccounts] objectAtIndex:[indexPath row]];
        if (acctInfo) { //display account detail information
            AccountStatusViewController *acctStatusController = [[AccountStatusViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [acctStatusController setAcctInfo:acctInfo];
            [IpadSupport pushDetailController:acctStatusController withNavigation:self.navigationController andSender:self];
        }
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Button Handlers
- (void) processAddButtonAction:(id) sender {
    AccountViewController *accountController = [[AccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [accountController setIsEdit:NO];
    [accountController setIsNew:YES];
    [accountController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [IpadSupport presentModalViewController:accountController withNavigation:self.navigationController];
}

- (void)handleAccountListUpdated:(NSNotification *)notification {
    [self.tableView reloadData];
}

@end
