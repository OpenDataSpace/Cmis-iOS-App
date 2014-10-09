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

@interface SettingsViewController ()
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
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.tableHeaders) {
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

@end
