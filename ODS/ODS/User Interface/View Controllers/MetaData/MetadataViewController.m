//
//  MetadataViewController.m
//  ODS
//
//  Created by bdt on 9/21/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "MetadataViewController.h"
#import "CustomTableViewCell.h"
#import "DownloadManager.h"
#import "UIImageView+WebCache.h"

#import "FileUtils.h"

#import "CMISRenditionData.h"
#import "CMISRendition.h"

#define PREVIEW_CELL_HEIGHT        200.0

static NSString * const kDownloadModelIdentifier = @"DownloadModelIdentifier";
static NSString * const kPreviewModelIdentifier = @"PreviewModelIdentifier";

@interface MetadataViewController ()

@end

@implementation MetadataViewController
@synthesize cmisObject = _cmisObject;
@synthesize selectedAccountUUID = _selectedAccountUUID;
@synthesize repositoryID = _repositoryID;

- (id)initWithStyle:(UITableViewStyle)style cmisObject:(CMISObject *)cmisObj accountUUID:(NSString *)uuid repositoryID:(NSString*) repoId {
    if (self = [super initWithStyle:style]) {
        _cmisObject = cmisObj;
        _selectedAccountUUID = uuid;
        _repositoryID = repoId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem setTitle:_cmisObject.name];
    [self createTableCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.tableSections) {
        return [self.tableSections count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    CustomTableViewCell *cell = (CustomTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell modelIdentifier] && [[cell modelIdentifier] isEqualToCaseInsensitiveString:kDownloadModelIdentifier]) {
        //start download
        if ([[DownloadManager sharedManager] isManagedDownload:_cmisObject.identifier]) {
            SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
                                                                inView:activeView()
                                                               message:[NSString stringWithFormat:@"%@ %@", _cmisObject.name, NSLocalizedString(@"dwonload.ismanaged", @"have already downloaded.")]
                                                                 title:@""];
            notice.displayTime = 3.0;
            [notice show];
        }else {
            SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
                                                                inView:activeView()
                                                               message:[NSString stringWithFormat:@"%@ %@", _cmisObject.name, NSLocalizedString(@"download.progress.starting", @"Download starting...")]
                                                                 title:@""];
            notice.displayTime = 3.0;
            [notice show];
            [[DownloadManager sharedManager] queueRepositoryItems:[NSArray arrayWithObject:_cmisObject] withAccountUUID:self.selectedAccountUUID withRepositoryID:self.repositoryID andTenantId:nil];
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
    
    if (self.tableSections && [self.tableSections count] > 0) {
        NSArray *cellArray = [self.tableSections objectAtIndex:indexPath.section];
        CustomTableViewCell *cell = (CustomTableViewCell*)[cellArray objectAtIndex:indexPath.row];
        if ([cell modelIdentifier] && [[cell modelIdentifier] isEqualToCaseInsensitiveString:kPreviewModelIdentifier]) {
            return PREVIEW_CELL_HEIGHT;
        }
    }
    
    return  44.0f;
}

- (BOOL) enableRefreshController {
    return NO;
}

#pragma mark -
#pragma mark Helper Methods

- (void) createTableCells {
    self.tableHeaders = [NSMutableArray array];
    self.tableSections = [NSMutableArray array];
    
    //basic info group
    NSMutableArray *basicGroup = [NSMutableArray array];
    [self.tableHeaders addObject:NSLocalizedString(@"metadata.group.header.general", @"General")];
    
    //name
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    [cell.textLabel setText:NSLocalizedString(@"cmis:name", @"Name")];
    [cell.detailTextLabel setText:_cmisObject.name];
    [basicGroup addObject:cell];
    
    //create by
    if (_cmisObject.createdBy) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        [cell.textLabel setText:NSLocalizedString(@"cmis:createdBy", @"createBy")];
        [cell.detailTextLabel setText:_cmisObject.createdBy];
        [basicGroup addObject:cell];
    }
    
    //creation date
    if (_cmisObject.creationDate) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        [cell.textLabel setText:NSLocalizedString(@"cmis:creationDate", @"creationDate")];
        [cell.detailTextLabel setText:formatDateTimeFromDate(_cmisObject.creationDate)];
        [basicGroup addObject:cell];
    }
    
    //lastmodifiedBy
    if (_cmisObject.lastModifiedBy) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        [cell.textLabel setText:NSLocalizedString(@"cmis:lastModifiedBy", @"lastModifiedBy")];
        [cell.detailTextLabel setText:_cmisObject.lastModifiedBy];
        [basicGroup addObject:cell];
    }
    
    //lastmodification date
    if (_cmisObject.lastModificationDate) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        [cell.textLabel setText:NSLocalizedString(@"cmis:lastModificationDate", @"lastModificationDate")];
        [cell.detailTextLabel setText:formatDateTimeFromDate(_cmisObject.lastModificationDate)];
        [basicGroup addObject:cell];
    }
    
    //cm:author
    
    //version
    
    [self.tableSections addObject:basicGroup];
    
    //download action
    if (!isCMISFolder(_cmisObject)) {  //Not support to download a folder
         NSMutableArray *downloadActionGroup = [NSMutableArray array];
        [self.tableHeaders addObject:NSLocalizedString(@"metadata.group.header.action", @"ACTIONS")];
        
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setText:NSLocalizedString(@"metadata.button.download", @"download")];
        [cell setModelIdentifier:kDownloadModelIdentifier];
        [downloadActionGroup addObject:cell];
        
        [self.tableSections addObject:downloadActionGroup];
    }
    
    //preview
    if (_cmisObject.renditions) {
        NSMutableArray *previewGroup = [NSMutableArray array];
        
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width,PREVIEW_CELL_HEIGHT)];
        imageView.tag = 1001;
        if (IS_IPAD) {
            imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        }else {
            imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        }
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self downloadThumbnailWithImageView:imageView];
        
        [cell addSubview:imageView];
        
        [cell setModelIdentifier:kPreviewModelIdentifier];
        
        [previewGroup addObject:cell];
        
        [self.tableHeaders addObject:NSLocalizedString(@"metadata.group.header.preview", @"PREVIEW")];
        [self.tableSections addObject:previewGroup];
    }
}

- (void) downloadThumbnailWithImageView:(UIImageView*) imgView {
    NSNumber *lastWidth = nil;
    NSNumber *lastHeight = nil;
    CMISRenditionData *maxSizeRendition = nil;
    if (_cmisObject && _cmisObject.renditions) {
        for (CMISRenditionData *rendition in _cmisObject.renditions) {
            if (rendition) {
                if ([lastWidth floatValue]*[lastHeight floatValue] < [rendition.width floatValue]*[rendition.height floatValue]) {
                    maxSizeRendition = rendition;
                    lastWidth = rendition.width;
                    lastHeight = rendition.height;
                }
            }
        }
    }
    
    if (maxSizeRendition) {
        NSString *tmpFile = [FileUtils pathToTempFile:maxSizeRendition.streamId];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL bNeedDownload = YES;
        
        if ([fileManager fileExistsAtPath:tmpFile]) {
            [imgView setImage:[UIImage imageWithContentsOfFile:tmpFile]];
            NSError *error = nil;
            NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:tmpFile error:&error];
            if (error) {
                ODSLogError(@"%@", error);
                [fileManager removeItemAtPath:tmpFile error:nil];
            }else {
                long long fileSize = [[fileAttr valueForKey:@"NSFileSize"] longLongValue];
                if (fileSize == [maxSizeRendition.length longLongValue]) {  //use the cache file
                    bNeedDownload = NO;
                    [imgView setImage:[UIImage imageWithContentsOfFile:tmpFile]];
                }

            }
        }
        if (bNeedDownload) {
            CMISRendition *currentRendition = [[CMISRendition alloc] initWithRenditionData:maxSizeRendition objectId:_cmisObject.identifier session:_cmisObject.session];
            [currentRendition downloadRenditionContentToFile:tmpFile completionBlock:^(NSError* error) {
                if (error) {
                    ODSLogError(@"%@", error);
                }else {
                    [imgView setImage:[UIImage imageWithContentsOfFile:tmpFile]];
                }
            } progressBlock:nil];
        }
    }
    
}

@end
