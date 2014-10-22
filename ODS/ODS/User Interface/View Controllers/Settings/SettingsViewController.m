//
//  SettingsViewController.m
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "SettingsViewController.h"

#import "UISwitchTableViewCell.h"
#import "CheckMarkTableViewCell.h"
#import "DeleteCacheTableViewCell.h"
#import "FileUtils.h"
#import "PreviewCacheManager.h"

#define kAlertTagCleanCache 10010

static NSString * const kDeleteCacheModelIdentifier = @"DeleteCacheModelIdentifier";

@interface SettingsViewController ()
@property (nonatomic, strong) DirectoryWatcher *dirWatcher;
@property (nonatomic, strong) DeleteCacheTableViewCell *cleanCacheCell;
@end

@implementation SettingsViewController

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
    [self.navigationItem setTitle:NSLocalizedString(@"settings.view.title", @"Settings")];
    
    [self setDirWatcher:[DirectoryWatcher watchFolderWithPath:[self directoryPreviewCache]
                                                     delegate:self]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createSettingItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tableSections) {
        return [self.tableSections count];
    }
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *optionsOfSection = nil;
    
    if (self.tableSections) {
        optionsOfSection = [self.tableSections objectAtIndex:section];
        
        return [optionsOfSection count];
    }
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *optionsOfSection = nil;
    
    if (self.tableSections) {
        optionsOfSection = [self.tableSections objectAtIndex:indexPath.section];
        
        return [optionsOfSection objectAtIndex:indexPath.row];
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *optionsOfSection = nil;
    
    if (self.tableSections) {
        optionsOfSection = [self.tableSections objectAtIndex:indexPath.section];
        UITableViewCell *cell =  [optionsOfSection objectAtIndex:indexPath.row];
        if ([cell isKindOfClass:[CheckMarkTableViewCell class]]) {
            CheckMarkTableViewCell *checkMarkCell = (CheckMarkTableViewCell*)cell;
            CheckMarkViewController *checkMarkController = [[CheckMarkViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [checkMarkController setCheckMarkDelegate:self];
            [checkMarkController setOptions:[checkMarkCell checkOptions]];
            [checkMarkController setSelectedIndex:[checkMarkCell selectedIndex]];
            [checkMarkController setViewTitle:checkMarkCell.textLabel.text];
            [checkMarkController setCheckMarkCell:checkMarkCell];
            
            [self.navigationController pushViewController:checkMarkController animated:YES];
        }else if ([cell isKindOfClass:[DeleteCacheTableViewCell class]]) {
            [self alertCleanPreviewCache];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.tableHeaders && [self.tableHeaders count] > section) {
       return [self.tableHeaders objectAtIndex:section];
    }
    return @"";
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (BOOL) enableRefreshController {
    return NO;
}

#pragma mark -
#pragma mark Helpers

- (void) createSettingItems {
    self.tableHeaders = [NSMutableArray array];
    self.tableSections = [NSMutableArray array];
    
    NSString *settingsBundlePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundlePath)
    {
        ODSLogError(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundlePath stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableArray *settingItems = nil;
    
    NSBundle *settingsBundle = [NSBundle bundleWithPath:settingsBundlePath];
    for(NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        NSString *titleIdentifier = [prefSpecification objectForKey:@"Title"];
        if(key)
        {
            NSString *settingType = [prefSpecification objectForKey:@"Type"];
            if ([settingType isEqualToCaseInsensitiveString:@"PSToggleSwitchSpecifier"]) {
                UISwitchTableViewCell *cell = (UISwitchTableViewCell*)[self createTableViewCellFromNib:@"UISwitchTableViewCell"];
                [cell setModelIdentifier:key];
                [cell.labelTitle setText:NSLocalizedStringFromTableInBundle(titleIdentifier, @"Root", settingsBundle, @"")];
                [cell.switchButton setOn:[[ODSUserDefaults standardUserDefaults] boolForKey:cell.modelIdentifier] animated:YES];
                [cell.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventValueChanged];
                [settingItems addObject:cell];
            }else if ([settingType isEqualToCaseInsensitiveString:@"PSMultiValueSpecifier"]) {
                CheckMarkTableViewCell *cell = (CheckMarkTableViewCell*) [self createTableViewCellFromNib:@"CheckMarkTableViewCell"];
                [cell setModelIdentifier:key];
                [cell.textLabel setText:NSLocalizedStringFromTableInBundle(titleIdentifier, @"Root", settingsBundle, @"")];
                [cell setCheckOptions:[self readCheckMarkOptions:prefSpecification bundle:settingsBundle]];
                [cell setSelectedIndex:[[ODSUserDefaults standardUserDefaults] integerForKey:cell.modelIdentifier]];
                [settingItems addObject:cell];
            }
        } else {
            [self.tableHeaders addObject:NSLocalizedStringFromTableInBundle(titleIdentifier, @"Root", settingsBundle, @"")];
            if (settingItems) {
                [self.tableSections addObject:settingItems];
            }
            settingItems = [NSMutableArray array];
        }
    }
    
    if (settingItems) {  //to add the last section
        [self.tableSections addObject:settingItems];
    }
    
    //add preview cache clean button
    NSMutableArray *deleteGroup = [NSMutableArray array];
    DeleteCacheTableViewCell *cell = [[DeleteCacheTableViewCell alloc] initWithReuseIdentifier:@""];
    [cell setModelIdentifier:kDeleteCacheModelIdentifier];
    [cell.textLabel setText:NSLocalizedString(@"settings.cmisRepository.CleanPreviewCache", @"Clean Preview Caches")];
    [cell.detailTextLabel setText:[[PreviewCacheManager sharedManager] previewCahceSize]];
    
    self.cleanCacheCell = cell;
    [deleteGroup addObject:cell];
    
    [self.tableSections addObject:deleteGroup];
}

- (NSArray*) readCheckMarkOptions:(NSDictionary*) prefSpecification bundle:(NSBundle*) bundle {
    NSArray *titleIdentifiers = [prefSpecification objectForKey:@"Titles"];
    NSMutableArray *titles = [NSMutableArray array];
    
    for (NSString *titlesIdentifier in titleIdentifiers) {
        [titles addObject:NSLocalizedStringFromTableInBundle(titlesIdentifier, @"Root", bundle, @"")];
    }
    
    return titles;
}

- (void) switchButtonPressed:(id) sender {
    UIView *senderView = (UIView*)sender;
    UISwitchTableViewCell *cell = (UISwitchTableViewCell *) senderView.superview;
    while (1) {
        if ([cell isKindOfClass:[UISwitchTableViewCell class]]) {  //find cell class
            break;
        }
        cell = (UISwitchTableViewCell *) cell.superview;
    }
    
    [[ODSUserDefaults standardUserDefaults] setBool:cell.switchButton.on forKey:cell.modelIdentifier];
}

- (void) selectCheckMarkOption:(NSInteger) index withCell:(CheckMarkTableViewCell*) cell {
    [cell setSelectedIndex:index];
    [[ODSUserDefaults standardUserDefaults] setInteger:index forKey:cell.modelIdentifier];
}

#pragma mark -
#pragma mark Folder watcher Delegate
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher {
    self.cleanCacheCell.detailTextLabel.text = [[PreviewCacheManager sharedManager] previewCahceSize];
}

- (NSString*) directoryPreviewCache {
    return [FileUtils pathToCacheFile:@""];
}

- (void) cleanPreviewCache {
    __block MBProgressHUD *hud = createAndShowProgressHUDForView(self.navigationController.view);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PreviewCacheManager sharedManager] removeAllCacheFiles];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cleanCacheCell.detailTextLabel.text = [[PreviewCacheManager sharedManager] previewCahceSize];
            stopProgressHUD(hud);
            hud = nil;
        });
    });
}

- (void) alertCleanPreviewCache {
    if (IS_IPAD) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"confirm.cleanPreviewCache.prompt.message", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"confirm.cleanPreviewCache.prompt.cancel", @"") otherButtonTitles:NSLocalizedString(@"confirm.cleanPreviewCache.prompt.ok", @""), nil];
        alerView.tag = kAlertTagCleanCache;
        [alerView show];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"confirm.cleanPreviewCache.prompt.message", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"confirm.cleanPreviewCache.prompt.cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"confirm.cleanPreviewCache.prompt.ok", @""), nil];
        actionSheet.tag = kAlertTagCleanCache;
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

#pragma mark -
#pragma mark UIAlertView delegate && UIActionSheet delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTagCleanCache && buttonIndex == 1) {  //clean cache
        [self cleanPreviewCache];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kAlertTagCleanCache && buttonIndex == 0) { //clean cache
        [self cleanPreviewCache];
    }
}
@end
