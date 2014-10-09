//
//  UploadsViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadsViewController.h"
#import "UploadsManager.h"
#import "RepositoryNodeViewCell.h"

@interface UploadsViewController ()

@end

@implementation UploadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:NSLocalizedString(@"manage.uploads.view.title", @"Uploads")];
    [self createUploadCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark UITableView Delegate & Datasource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[UploadsManager sharedManager] allUploads] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableSections) {
        NSArray *uploads = [self.tableSections objectAtIndex:indexPath.section];
        return [uploads objectAtIndex:indexPath.row];
    }
    return nil;
}

- (void) createUploadCells {
    self.tableSections = [NSMutableArray array];
    
    NSArray *uploads = [[UploadsManager sharedManager] allUploads];
    NSMutableArray *uploadSection = [NSMutableArray array];
    
    RepositoryNodeViewCell *cell = nil;
    for (UploadInfo *upload in uploads) {
        cell = (RepositoryNodeViewCell*)[self createTableViewCellFromNib:@"RepositoryNodeViewCell"];
        
        [cell.lblFileName setText:[upload completeFileName]];
        [cell.imgIcon setImage:imageForFilename([upload completeFileName])];
        [cell.lblDetails setHidden:YES];
        [cell.progressBar setProgress:[upload uploadedProgress]];
        [cell.progressBar setHidden:NO];
        [upload.uploadRequest setUploadProgressDelegate:cell.progressBar];
        [uploadSection addObject:cell];
    }
    
    [self.tableSections addObject:uploadSection];
}

- (BOOL) enableRefreshController {
    return NO;
}

@end
