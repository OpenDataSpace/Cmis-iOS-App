//
//  DownloadsViewController.m
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DownloadsViewController.h"
#import "FolderTableViewDataSource.h"
#import "ActiveDownloadsViewController.h"
#import "FailedDownloadsViewController.h"
#import "DownloadSummaryTableViewCell.h"
#import "DownloadFailureSummaryTableViewCell.h"
#import "DocumentViewController.h"
#import "FileUtils.h"

@interface DownloadsViewController ()
@property (nonatomic, strong) NSMutableArray    *downloadedFiles;
@property (nonatomic, strong) NSDictionary      *downloadedMeta;
@property (nonatomic, strong) NSURL             *docsFolderURL;
@end

@interface DownloadsViewController (Private)

- (NSString *)applicationDocumentsDirectory;
- (void)selectCurrentRow;
@end

@implementation DownloadsViewController
@synthesize dirWatcher = _dirWatcher;
@synthesize selectedFile = _selectedFile;
@synthesize folderDatasource = _folderDatasource;
@synthesize documentFilter = _documentFilter;

#pragma mark Memory Management
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _dirWatcher = nil;
    _selectedFile = nil;
    _folderDatasource = nil;
    _documentFilter = nil;
}

- (void) awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadQueueChanged:) name:kNotificationDownloadQueueChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailViewControllerChanged:) name:kDetailViewControllerChangedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.folderDatasource refreshData];
    [self.tableView reloadData];
    [self selectCurrentRow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.title)
    {
        [self setTitle:NSLocalizedString(@"downloads.view.title", @"Downloads View Title")];
    }
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.docsFolderURL = [NSURL fileURLWithPath:[self applicationDocumentsDirectory] isDirectory:YES];
    
    FolderTableViewDataSource *dataSource = [[FolderTableViewDataSource alloc] initWithURL:self.docsFolderURL andDocumentFilter:self.documentFilter];
    [self setFolderDatasource:dataSource];
    [[self tableView] setDataSource:dataSource];
    [[self tableView] reloadData];
    if ([[self tableView] respondsToSelector:@selector(setSeparatorInset:)]) {
        [[self tableView] setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // start monitoring the document directory…
    [self setDirWatcher:[DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory]
                                                     delegate:self]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FolderTableViewDataSource *dataSource = (FolderTableViewDataSource *)[tableView dataSource];
    NSString *key = [[dataSource sectionKeys] objectAtIndex:indexPath.section];
    
    if ([key isEqualToString:kDownloadManagerSection])
    {
        NSString *cellType = [dataSource cellDataObjectForIndexPath:indexPath];
        if ([cellType hasPrefix:kDownloadSummaryCellIdentifier])
        {
            ActiveDownloadsViewController *viewController = [[ActiveDownloadsViewController alloc] init];
            [viewController setTitle:NSLocalizedString(@"download.summary.title", @"In Progress")];
            [self.navigationController pushViewController:viewController animated:YES];
            ODSLogTrace(@"in progress downloads.....");
        }
        else if ([cellType isEqualToString:kDownloadFailureSummaryCellIdentifier])
        {
            FailedDownloadsViewController *viewController = [[FailedDownloadsViewController alloc] init];
            [viewController setTitle:NSLocalizedString(@"download.failuresView.title", @"Download Failures")];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else
    {
        [self showDocument];
    }
}

- (BOOL) enableRefreshController {
    return NO;
}

- (void) showDocument
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    FolderTableViewDataSource *dataSource = (FolderTableViewDataSource *)[self.tableView dataSource];
    
    NSURL *fileURL = [dataSource cellDataObjectForIndexPath:indexPath];
    DownloadMetadata *downloadMetadata = [dataSource downloadMetadataForIndexPath:indexPath];
    NSString *fileName = [[fileURL path] lastPathComponent];
    
    UIStoryboard *mainStoryboard = instanceMainStoryboard();
    DocumentViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DocumentControllerIdentifier"];
        
    if (downloadMetadata && downloadMetadata.key)
    {
        [viewController setFileName:downloadMetadata.key];
    }
    else
    {
        [viewController setFileName:fileName];
    }
    
    viewController.fileMetadata = downloadMetadata;
    [viewController setCmisObjectId:[downloadMetadata objectId]];
    [viewController setFilePath:[FileUtils pathToSavedFile:fileName]];
    [viewController setContentMimeType:[downloadMetadata contentStreamMimeType]];
    [viewController setHidesBottomBarWhenPushed:YES];
    [viewController setIsDownloaded:YES];
    [viewController setSelectedAccountUUID:[downloadMetadata accountUUID]];
    [viewController setShowReviewButton:NO];
    
    [IpadSupport pushDetailController:viewController withNavigation:self.navigationController andSender:self];
    
    self.selectedFile = fileURL;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    FolderTableViewDataSource *dataSource = (FolderTableViewDataSource *)[tableView dataSource];
    NSString *key = [[dataSource sectionKeys] objectAtIndex:indexPath.section];
    
    if ([key isEqualToString:kDownloadedFilesSection] && ![(FolderTableViewDataSource *)[tableView dataSource] noDocumentsSaved])
    {
        editingStyle = UITableViewCellEditingStyleDelete;
    }
    
    return editingStyle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    FolderTableViewDataSource *dataSource = (FolderTableViewDataSource *)[tableView dataSource];
    NSString *key = [[dataSource sectionKeys] objectAtIndex:section];
    
    CGFloat height = 0.0f;
    if ([key isEqualToString:kDownloadedFilesSection])
    {
        height = 32.0f;
    }
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    FolderTableViewDataSource *dataSource = (FolderTableViewDataSource *)[tableView dataSource];
    
    UILabel *footerBackground = [[UILabel alloc] init];
    [footerBackground setText:[dataSource tableView:tableView titleForFooterInSection:section]];
    
    NSString *key = [[dataSource sectionKeys] objectAtIndex:section];
    
    if ([key isEqualToString:kDownloadedFilesSection])
    {
        [footerBackground setBackgroundColor:[UIColor whiteColor]];
        [footerBackground setTextAlignment:NSTextAlignmentCenter];
    }
    
    return footerBackground;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    FolderTableViewDataSource *dataSource = (FolderTableViewDataSource *)[tableView dataSource];
    NSString *key = [[dataSource sectionKeys] objectAtIndex:indexPath.section];
    
    if ([key isEqualToString:kDownloadedFilesSection]) {
        
    }
}

#pragma mark - DirectoryWatcherDelegate methods

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
    FolderTableViewDataSource *folderDataSource = (FolderTableViewDataSource *)[self.tableView dataSource];
    
    /* We disable the automatic table view refresh while editing to get an animated
     effect. The automatic refresh is activated after only one time it was disabled.
     */
    if (!folderDataSource.editing)
    {
        ODSLogDebug(@"Reloading downloads tableview");
        [folderDataSource refreshData];
        [self.tableView reloadData];
        [self selectCurrentRow];
    }
    else
    {
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        folderDataSource.editing = NO;
        if ([folderDataSource noDocumentsSaved]) {
            [self setEditing:NO];
        }
    }
}

#pragma mark - File system support

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)selectCurrentRow
{
    NSURL *fileURL = self.selectedFile;
    if (!fileURL)
    {
        fileURL = [IpadSupport getCurrentDetailViewControllerFileURL];
    }
    
    FolderTableViewDataSource *folderDataSource = (FolderTableViewDataSource *)[self.tableView dataSource];
    if (IS_IPAD)
    {
        NSArray *pathComponents = [fileURL pathComponents];
        if ([pathComponents containsObject:@"Documents"] && [folderDataSource.children containsObject:fileURL])
        {
            NSIndexPath *selectedIndex = [NSIndexPath indexPathForRow:[folderDataSource.children indexOfObject:fileURL] inSection:0];
            [self.tableView selectRowAtIndexPath:selectedIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
            self.selectedFile = fileURL;
        }
        else
        {
            if (self.tableView.indexPathForSelectedRow != nil)
            {
                [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
            }
            self.selectedFile = nil;
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = (folderDataSource.children.count > 0);
    if (folderDataSource.children.count == 0)
    {
        [self setEditing:NO];
    }
}

- (NSIndexPath *)indexPathForItemWithTitle:(NSString *)itemTitle
{
    NSIndexPath *indexPath = nil;
    NSMutableArray *items = self.folderDatasource.children;
    
    if (itemTitle != nil && items != nil)
    {
        // Define a block predicate to search for the item being viewed
        BOOL (^matchesRepostoryItem)(NSString *, NSUInteger, BOOL *) = ^ (NSString *cellTitle, NSUInteger idx, BOOL *stop)
        {
            BOOL matched = NO;
            NSString *fileURLString = [(NSURL *)cellTitle path];
            
            if ([[fileURLString lastPathComponent] isEqualToString:itemTitle] == YES)
            {
                matched = YES;
                *stop = YES;
            }
            return matched;
        };
        
        // See if there's an item in the list with a matching guid, using the block defined above
        NSUInteger matchingIndex = [items indexOfObjectPassingTest:matchesRepostoryItem];
        if (matchingIndex != NSNotFound)
        {
            indexPath = [NSIndexPath indexPathForRow:matchingIndex inSection:0];
        }
    }
    
    return indexPath;
}

#pragma mark - NotificationCenter methods

- (void)detailViewControllerChanged:(NSNotification *)notification
{
    id sender = [notification object];
    
    if (sender && ![sender isEqual:self])
    {
        self.selectedFile = nil;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

#pragma mark - DownloadManager Notification methods

- (void)downloadQueueChanged:(NSNotification *)notification {
    NSArray *failedDownloads = [[DownloadManager sharedManager] failedDownloads];
    NSInteger activeCount = [[[DownloadManager sharedManager] activeDownloads] count];
    
    if ([failedDownloads count] > 0)
    {
        [self.navigationController.tabBarItem setBadgeValue:@"!"];
    }
    else if (activeCount > 0)
    {
        [self.navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", activeCount]];
    }
    else
    {
        [self.navigationController.tabBarItem setBadgeValue:nil];
        [self.folderDatasource refreshData];
        [self.tableView reloadData];
    }
}
@end
