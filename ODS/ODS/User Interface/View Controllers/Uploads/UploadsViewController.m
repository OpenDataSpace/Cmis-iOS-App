//
//  UploadsViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadsViewController.h"
#import "UploadsManager.h"
#import "UploadProgressTableViewCell.h"

@interface UploadsViewController ()

@end

@implementation UploadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:NSLocalizedString(@"manage.uploads.view.title", @"Uploads")];
    [self createUploadCells];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadQueueChanged:) name:kNotificationUploadQueueChanged object:nil];
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
    
    UploadProgressTableViewCell *cell = nil;
    for (UploadInfo *upload in uploads) {
        cell = (UploadProgressTableViewCell*)[self createTableViewCellFromNib:@"UploadProgressTableViewCell"];
        
        [cell setUploadInfo:upload];
        [uploadSection addObject:cell];
    }
    
    [self.tableSections addObject:uploadSection];
}

- (BOOL) enableRefreshController {
    return NO;
}

#pragma mark - NSNotificationCenter methods
- (void)uploadQueueChanged:(NSNotification *) notification {
    @synchronized(self.tableSections)
    {
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        NSMutableArray *uploads = [self.tableSections objectAtIndex:0];
        for (NSUInteger index = 0; index < [uploads count]; index++) {
            UploadProgressTableViewCell *cellWrapper = [uploads objectAtIndex:index];
            // We keep the cells for finished uploads and failed uploads
            if (cellWrapper.uploadInfo && [cellWrapper.uploadInfo uploadStatus] != UploadInfoStatusUploaded && ![[UploadsManager sharedManager] isManagedUpload:cellWrapper.uploadInfo.uuid])
            {
                ODSLogTrace(@"We are displaying an upload that is not currently managed");
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [indexPaths addObject:indexPath];
                [indexSet addIndex:index];
            }
        }
        
        if ([indexPaths count] > 0)
        {
            [uploads removeObjectsAtIndexes:indexSet];
            [self.tableView reloadData];
        }
    }
}
@end
