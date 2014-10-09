//
//  AccountStatusViewController.m
//  ODS
//
//  Created by bdt on 9/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AccountStatusViewController.h"
#import "UISwitchTableViewCell.h"
#import "AccountViewController.h"
#import "AccountManager.h"

@interface AccountStatusViewController ()

@end

@implementation AccountStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem setTitle:self.acctInfo.vendor];
    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(processEditButtonAction:)];
    [self.navigationItem setRightBarButtonItem:editBarItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccountListUpdated:)
                                                 name:kNotificationAccountListUpdated object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createAccountComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) enableRefreshController {
    return NO;
}

- (void) createAccountComponents {
    self.tableHeaders = [NSMutableArray array];
    self.tableSections = [NSMutableArray array];
    
    //account status
    [self.tableHeaders addObject:NSLocalizedString(@"accountdetails.header.status", @"Status")];
    UISwitchTableViewCell *statusCell = (UISwitchTableViewCell*)[self createTableViewCellFromNib:@"UISwitchTableViewCell"];
    [statusCell.labelTitle setText:NSLocalizedString(@"accountdetails.fields.status", @"")];
    [statusCell.switchButton setOn:[self.acctInfo.accountStatusInfo isActive]];
    [statusCell.switchButton addTarget:self action:@selector(processSwitchStatusButtonAction:) forControlEvents:UIControlEventValueChanged];
    [self.tableSections addObject:[NSArray arrayWithObject:statusCell]];
    
    //account authentication
    [self.tableHeaders addObject:NSLocalizedString(@"accountdetails.header.authentication", @"Account Authentication")];
    UITableViewCell *cellUser = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellUser.textLabel setText:NSLocalizedString(@"accountdetails.fields.username", @"Username")];
    [cellUser.detailTextLabel setText:[self.acctInfo username]];
    
    UITableViewCell *cellPassword = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellPassword.textLabel setText:NSLocalizedString(@"accountdetails.fields.password", @"Password")];
    [cellPassword.detailTextLabel setText:@"********"];
    
    UITableViewCell *cellServer = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellServer.textLabel setText:NSLocalizedString(@"accountdetails.fields.hostname", @"Server Address")];
    [cellServer.detailTextLabel setText:[self.acctInfo hostname]];
    
    UITableViewCell *cellDesc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellDesc.textLabel setText:NSLocalizedString(@"accountdetails.fields.description", @"Description")];
    [cellDesc.detailTextLabel setText:[self.acctInfo vendor]];
    
    UITableViewCell *cellProtocol = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellProtocol.textLabel setText:NSLocalizedString(@"accountdetails.fields.protocol", @"HTTPS")];
    [cellProtocol.detailTextLabel setText:[[self.acctInfo protocol]
                                  isEqualToCaseInsensitiveString:kFDHTTPS_Protocol]?NSLocalizedString(@"account.protocol.https.on", @"On"):NSLocalizedString(@"account.protocol.https.off", @"Off")];
    
    [self.tableSections addObject:[NSArray arrayWithObjects:cellUser, cellPassword, cellServer, cellDesc, cellProtocol, nil]];
    
    //advanced
    [self.tableHeaders addObject:NSLocalizedString(@"accountdetails.header.advanced", @"Advanced")];
    UITableViewCell *cellPort = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellPort.textLabel setText:NSLocalizedString(@"accountdetails.fields.port", @"Port")];
    [cellPort.detailTextLabel setText:[self.acctInfo port]];
    
    UITableViewCell *cellServiceProtocol = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellServiceProtocol.textLabel setText:NSLocalizedString(@"accountdetails.fields.serviceprotocol", @"CMIS Protocol")];
    [cellServiceProtocol.detailTextLabel setText:[CMISUtility cmisProtocolToString:[self.acctInfo cmisType]]];

    UITableViewCell *cellServiceDoc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cellServiceDoc.textLabel setText:NSLocalizedString(@"accountdetails.fields.servicedoc", @"Service Document")];
    [cellServiceDoc.detailTextLabel setText:[self.acctInfo serviceDocumentRequestPath]];
    
    [self.tableSections addObject:[NSArray arrayWithObjects:cellPort, cellServiceProtocol, cellServiceDoc, nil]];
    
    //browse documents (must be active)
    if ([self.acctInfo.accountStatusInfo isActive]) {
        UITableViewCell *cellBrowse = [[UITableViewCell alloc] init];
        [cellBrowse.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cellBrowse.textLabel setText:NSLocalizedString(@"accountdetails.buttons.browse", @"Browse Documents")];
        [self.tableSections addObject:[NSArray arrayWithObject:cellBrowse]];
    }
    
    //delete account
    UITableViewCell *cellDelete = [[UITableViewCell alloc] init];
    [cellDelete.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cellDelete setBackgroundColor:[UIColor redColor]];
    [cellDelete.textLabel setTextColor:[UIColor whiteColor]];
    [cellDelete.textLabel setText:NSLocalizedString(@"accountdetails.buttons.delete", @"Delete Account")];
    [self.tableSections addObject:[NSArray arrayWithObject:cellDelete]];
}

#pragma mark -
#pragma mark UITableView delegate & datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tableSections) {
        return [self.tableSections count];
    }
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableSections) {
        NSArray *itemsOfSection = [self.tableSections objectAtIndex:section];
        if (itemsOfSection) {
            return [itemsOfSection count];
        }
    }
    
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableSections) {
        NSArray *itemsOfSection = [self.tableSections objectAtIndex:indexPath.section];
        if (itemsOfSection) {
            UITableViewCell *cell = [itemsOfSection objectAtIndex:indexPath.row];
            if (cell) {
                return cell;
            }
        }
    }
    return nil;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.tableHeaders && [self.tableHeaders count] > section) {
        return [self.tableHeaders objectAtIndex:section];
    }
    return @"";
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark -
#pragma mark Actions of Bar Item
- (void) processEditButtonAction:(id) sender {
    AccountViewController *accountController = [[AccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [accountController setAcctInfo:self.acctInfo];
    [accountController setIsEdit:YES];
    [accountController setIsNew:NO];
    [accountController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [IpadSupport presentModalViewController:accountController withNavigation:self.navigationController];
}

- (void) processSwitchStatusButtonAction:(id) sender {
    UISwitch *switchButton = (UISwitch*) sender;
    
    if ([switchButton isOn]) {
        [self.acctInfo setAccountStatus:FDAccountStatusActive];
    }else {
        [self.acctInfo setAccountStatus:FDAccountStatusInactive];
    }
    [self createAccountComponents];
    [self.tableView reloadData];
}

- (void)handleAccountListUpdated:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *type = [userInfo objectForKey:@"type"];
    if (type && [type isEqualToString:kAccountUpdateNotificationEdit]) {
        self.acctInfo = [[AccountManager sharedManager] accountInfoForUUID:self.acctInfo.uuid];
        [self createAccountComponents];
        [self.tableView reloadData];
    }
}
@end
