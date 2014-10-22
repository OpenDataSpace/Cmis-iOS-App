//
//  BrowseAccountsViewController.m
//  ODS
//
//  Created by bdt on 8/19/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "BrowseAccountsViewController.h"
#import "AccountManager.h"
#import "AccountViewCell.h"
#import "RepositoriesViewController.h"
#import "AccountInfo+URL.h"

#import "CMISSession.h"
#import "CMISBrowserBinding.h"
#import "CMISRepositoryInfo.h"

static NSString * const kBrowseAccountsCellIdentifier = @"BrowseAccountsCellIdentifier";

@interface BrowseAccountsViewController () {
    NSArray     *activeAccounts;
}

@end

@implementation BrowseAccountsViewController

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
    
    activeAccounts = nil;
    [[self navigationItem] setTitle:NSLocalizedString(@"browse.accounts.view.title", @"Accounts")];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountViewCell" bundle:nil] forCellReuseIdentifier:kBrowseAccountsCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBrowseDocuments:)
                                                 name:kBrowseDocumentsNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    activeAccounts = [[AccountManager sharedManager] activeAccounts];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [activeAccounts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBrowseAccountsCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    AccountInfo *acctInfo = [activeAccounts objectAtIndex:[indexPath row]];
    if (acctInfo) {        
        [cell setAccountInfo:acctInfo];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AccountInfo *acctInfo = [activeAccounts objectAtIndex:[indexPath row]];
    if (acctInfo) {
        [self loadRepositoriesWithAccount:acctInfo];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL) enableRefreshController {
    return NO;
}

#pragma mark -
#pragma mark Load Repositories
- (void) loadRepositoriesWithAccount:(AccountInfo*) acctInfo {
    [self startHUD];
    __block CMISSessionParameters *params = getSessionParametersWithAccountInfo(acctInfo, nil);
    
    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repos, NSError *error){
        [self stopHUD];
        if (error != nil) {
            ODSLogError(@"%@", error);
        }else {
            RepositoriesViewController *repositoryController = [[RepositoriesViewController alloc] initWithStyle:UITableViewStylePlain];
            [repositoryController setSelectedAccountUUID:[acctInfo uuid]];
            [repositoryController setViewTitle:[acctInfo vendor]];
            [repositoryController setRepositories:[CMISUtility filterRepositories:repos]];
            [repositoryController setSessionParameters:params];
            [self.navigationController pushViewController:repositoryController animated:YES];
        }
    }];
}

#pragma mark -
#pragma mark Notification Handler
- (void)handleBrowseDocuments:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(handleBrowseDocuments:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    NSString *uuidToBrowse = [[notification userInfo] objectForKey:@"accountUUID"];
    AccountInfo *accountInfo = [[AccountManager sharedManager] accountInfoForUUID:uuidToBrowse];
    
    [self loadRepositoriesWithAccount:accountInfo];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {  //to fix ios6 have no such property
        [self tabBarController].tabBar.translucent = NO;
    }
    
    [[self tabBarController] setSelectedViewController:[self navigationController]];
}

@end
