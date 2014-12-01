//
//  ChooserFolderViewController.m
//  ODS
//
//  Created by bdt on 10/19/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ChooserFolderViewController.h"
#import "RepositoryNodeViewCell.h"
#import "RepositoryViewCell.h"

#import "CMISSession.h"
#import "CMISPagedResult.h"
#import "CMISRepositoryInfo.h"
#import "CMISOperationContext.h"

NSString * const  kMoveTargetTypeRepo = @"TYPE_REPO";
NSString * const  kMoveTargetTypeFolder = @"TYPE_FOLDER";

@interface ChooserFolderViewController ()
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
@end

@implementation ChooserFolderViewController
@synthesize selectedAccountUUID = _selectedAccountUUID;
@synthesize viewTitle = _viewTitle;
@synthesize itemType = _itemType;
@synthesize folderItems = _folderItems;
@synthesize tenantID = _tenantID;
@synthesize repositoryID = _repositoryID;
@synthesize selectedDelegate = _selectedDelegate;
@synthesize parentItem = _parentItem;
@synthesize sourceFolder = _sourceFolder;
@synthesize selectedItems = _selectedItems;

- (id)initWithAccountUUID:(NSString *)uuid  sourceFolder:(CMISFolder*) srcFolder selectedItems:(NSArray*) selectedItems
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        _selectedAccountUUID = uuid;
        _folderItems = nil;
        _sourceFolder = srcFolder;
        _selectedItems = selectedItems;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationItem] setTitle:[self viewTitle]];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dialog.chooser.cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPress)];
    UIBarButtonItem *fixSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace        target:self action:nil];
    self.doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dialog.chooser.confirm", @"Choose") style:UIBarButtonItemStyleBordered target:self action:@selector(chooseButtonPress)];
    
    if (_parentItem != nil && ![self isSourceFolder:_parentItem]) {
        [self.doneBtn setEnabled:YES];
    }else {
        [self.doneBtn setEnabled:NO];
    }
    self.toolbarItems = [NSArray arrayWithObjects:cancelBtn, fixSpace,self.doneBtn, nil];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbarHidden = NO;
    
    //register table cell class
    [self.tableView registerNib:[UINib nibWithNibName:@"RepositoryViewCell" bundle:nil] forCellReuseIdentifier:kRepositoryCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //load repo list first
    [self.folderItems removeAllObjects];  //delete old folders
    if ([_itemType isEqualToString:kMoveTargetTypeRepo]) {
        [self loadRepositories];
    }else if ([_itemType isEqualToString:kMoveTargetTypeFolder]) {
        if (_parentItem == nil) {
            [self loadRootFolders];
        }else {
            [self loadFolders:self.parentItem];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource & Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_folderItems) {
        return [_folderItems count];
    }
    
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
    if ([_itemType isEqualToString:kMoveTargetTypeRepo]) {
        CMISRepositoryInfo *repoInfo = [[self folderItems] objectAtIndex:indexPath.row];
        if (repoInfo) {
            [cell lblRepositoryName].text = [repoInfo name];
            [cell.imgIcon setImage:[UIImage imageNamed:@"network"]];
        }
        
    }else if ([_itemType isEqualToString:kMoveTargetTypeFolder]){
        CMISFolder *fodler = [[self folderItems] objectAtIndex:indexPath.row];
        cell.lblRepositoryName.text = [fodler name];
        [cell.imgIcon setImage:[UIImage imageNamed:@"folder"]];        
       
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMISObject *item = [self.folderItems objectAtIndex:[indexPath row]];
    
    ChooserFolderViewController *folderViewController = [[ChooserFolderViewController alloc] initWithAccountUUID:self.selectedAccountUUID sourceFolder:_sourceFolder selectedItems:_selectedItems];
    [folderViewController setItemType:kMoveTargetTypeFolder];
    
    
    if ([item isKindOfClass:[CMISRepositoryInfo class]]) {
        CMISRepositoryInfo *repoInfo = (CMISRepositoryInfo*) item;
        [folderViewController setViewTitle:repoInfo.name];
        [folderViewController setRepositoryID:repoInfo.identifier];
        [folderViewController setParentItem:nil];
    }else {
        [folderViewController setParentItem:item];
        [folderViewController setViewTitle:item.name];
        [folderViewController setRepositoryID:self.repositoryID];
    }
    [folderViewController setItemType:kMoveTargetTypeFolder];
    [folderViewController setSelectedDelegate:_selectedDelegate];
    [self.navigationController pushViewController:folderViewController animated:YES];
}

- (BOOL) enableRefreshController {
    return NO;
}

#pragma mark -
#pragma mark Helper Methods

- (void) loadRepositories {
    [self startHUD];
    __block CMISSessionParameters *params = getSessionParametersWithAccountUUID(self.selectedAccountUUID, nil);
    
    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repos, NSError *error){
        [self stopHUD];
        if (error != nil) {
            ODSLogError(@"%@", error);
            [CMISUtility handleCMISRequestError:error];
        }else {
            [self setFolderItems:[NSMutableArray arrayWithArray:[CMISUtility filterRepositories:repos]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void) loadRootFolders {
    [self startHUD];
    __block CMISSessionParameters *params = getSessionParametersWithAccountUUID(self.selectedAccountUUID, self.repositoryID);
    
    [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *session, NSError *sessionError) {
        if (sessionError != nil) {
            [self stopHUD];
        }else {
            [session retrieveRootFolderWithCompletionBlock:^(CMISFolder *folder, NSError *error) {
                if (error) {
                    [self stopHUD];
                    ODSLogError(@"%@", error);
                    [CMISUtility handleCMISRequestError:error];
                }else {
                    self.parentItem = folder;
                    [folder retrieveChildrenWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:^(CMISPagedResult* results, NSError *error) {
                        [self stopHUD];
                        if (error) {
                            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
                            [CMISUtility handleCMISRequestError:error];
                        }else {
                            [self saveResult:results.resultArray];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void) loadFolders:(CMISFolder*) folder {
    [self startHUD];
    [folder retrieveChildrenWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:^(CMISPagedResult* results, NSError *error) {
        [self stopHUD];
        if (error) {
            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
            [CMISUtility handleCMISRequestError:error];
        }else {
            //[self loadMorePages:results];
            [self saveResult:results.resultArray];
        }
    }];
}

//- (void) loadMorePages:(CMISPagedResult*) pagedResult {
//    [self saveResult:pagedResult.resultArray];
//    if (!pagedResult.hasMoreItems) {
//        [self stopHUD];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.doneBtn setEnabled:![self isSourceFolder:_parentItem]];
//            [self.tableView reloadData];
//        });
//        return;
//    }
//    
//    [pagedResult fetchNextPageWithCompletionBlock:^(CMISPagedResult* results, NSError *error) {
//        if (error) {
//            [self stopHUD];
//        }else {
//            [self loadMorePages:results];
//        }
//    }];
//}

- (void) saveResult:(NSArray*) items {
    if (self.folderItems == nil) {
        self.folderItems = [NSMutableArray array];
    }
    
    for (CMISObject *item in items) {
        if (isCMISFolder(item) && ![self isSelectedObject:item]) {
            [self.folderItems addObject:item];
        }
    }
}

- (BOOL) isSourceFolder:(CMISObject*) object {
    if (object && [object.identifier isEqualToCaseInsensitiveString:_sourceFolder.identifier]) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isSelectedObject:(CMISObject*) object {
    if (object) {
        NSPredicate *uuidPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"identifier == '%@'", object.identifier]];
        NSArray *array = [_selectedItems filteredArrayUsingPredicate:uuidPredicate];
        if ([array count] > 0) {
            return YES;
        }
    }
   
    return NO;
}

#pragma mark - ToolBar Button Actions

- (void) cancelButtonPress {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) chooseButtonPress {
    if ([_selectedDelegate respondsToSelector:@selector(selectedItem:repositoryID:)]) {
        [_selectedDelegate selectedItem:_parentItem repositoryID:_repositoryID];
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
