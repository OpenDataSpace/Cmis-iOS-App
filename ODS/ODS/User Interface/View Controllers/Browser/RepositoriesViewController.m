//
//  RepositoriesViewController.m
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "RepositoriesViewController.h"
#import "RepositoryViewCell.h"
#import "CMISRepositoryInfo.h"
#import "RepositoryNodeViewController.h"
#import "AccountInfo.h"
#import "AccountInfo+URL.h"
#import "AccountManager.h"

#import "CMISSession.h"

@interface RepositoriesViewController () {
    CMISSession *session_;
    CMISFolder  *rootFolder;
}

@end

@implementation RepositoriesViewController

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
    
    [[self navigationItem] setTitle:[self viewTitle]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //register table cell class
    [self.tableView registerNib:[UINib nibWithNibName:@"RepositoryViewCell" bundle:nil] forCellReuseIdentifier:kRepositoryCellIdentifier];
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
    return [[self repositories] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CMISRepositoryInfo *repoInfo = [[self repositories] objectAtIndex:[indexPath row]];
    if (repoInfo) {
        [cell lblRepositoryName].text = [repoInfo name];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMISRepositoryInfo *repoInfo = [self.repositories objectAtIndex:[indexPath row]];
    
    if (repoInfo) {
        [self loadRootFolder:repoInfo];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIRefreshControl Handler
- (void)refresh:(id)sender
{
    ODSLogDebug(@"Refreshing data");
    [super refresh:sender];
    __block CMISSessionParameters *params = getSessionParametersWithAccountUUID([self selectedAccountUUID], nil);
    
    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repos, NSError *error){
        if (error != nil) {
            ODSLogError(@"%@", error);
            [CMISUtility handleCMISRequestError:error];
        }else {
            [self setRepositories:[CMISUtility filterRepositories:repos]];
        }
        [self endRefreshing];
    }];
}

#pragma mark -
#pragma mark Load Root Folder
- (void) loadRootFolder:(CMISRepositoryInfo *)repoInfo {
    [self startHUD];
    CMISSessionParameters *params = self.sessionParameters;
    params.repositoryId = repoInfo.identifier;
    
    [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *session, NSError *sessionError) {
        if (sessionError != nil) {
            [self stopHUD];
        }else {
            session_ = session;
            [session_ retrieveRootFolderWithCompletionBlock:^(CMISFolder *folder, NSError *error) {
                if (error) {
                    [self stopHUD];
                    ODSLogError(@"%@", error);
                    [CMISUtility handleCMISRequestError:error];
                }else {
                    rootFolder = folder;
                    [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult* results, NSError *error) {
                        [self stopHUD];
                        if (error) {
                            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
                            [CMISUtility handleCMISRequestError:error];
                        }else {
                            if (IS_IPAD)
                            {
                                [IpadSupport clearDetailController];
                            }
                            RepositoryNodeViewController *repoNodeController = [[RepositoryNodeViewController alloc] initWithStyle:UITableViewStylePlain];
                            [repoNodeController setFolder:rootFolder];
                            [repoNodeController setPagedFolders:results];
                            [repoNodeController setSelectedAccountUUID:self.selectedAccountUUID];
                            [repoNodeController setRepositoryIdentifier:repoInfo.identifier];
                            [self.navigationController pushViewController:repoNodeController animated:YES];
                        }
                    }];
                }
            }];
        }
    }];
}

@end
