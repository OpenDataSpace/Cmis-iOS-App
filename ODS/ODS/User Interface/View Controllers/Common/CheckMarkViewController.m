//
//  CheckMarkViewController.m
//  ODS
//
//  Created by bdt on 9/23/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CheckMarkViewController.h"

@interface CheckMarkViewController ()
@property (nonatomic, strong) NSMutableArray    *optionCells;
@end

@implementation CheckMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem setTitle:self.viewTitle];
    [self createCheckMarkOptions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.optionCells != nil) {
       return [self.optionCells count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.optionCells objectAtIndex:indexPath.row];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectedRowAt:indexPath.row];
    if (self.checkMarkDelegate) {
        [self.checkMarkDelegate selectCheckMarkOption:indexPath.row withCell:self.checkMarkCell];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Helpers
- (void) createCheckMarkOptions {
    if (self.optionCells == nil) {
        self.optionCells = [NSMutableArray array];
        
        for (int i = 0; i < [self.options count]; i ++) {
            NSString *option = [self.options objectAtIndex:i];
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            [cell.textLabel setText:option];
            [self.optionCells addObject:cell];
        }
    }
    
    [self selectedRowAt:self.selectedIndex];
}

- (void) selectedRowAt:(NSInteger) index {
    for (int i = 0; i < [self.optionCells count]; i ++) {
        UITableViewCell *cell = [self.optionCells objectAtIndex:i];
        if (i == index) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}
@end
