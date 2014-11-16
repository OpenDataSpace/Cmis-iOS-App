//
//  RepositoryNodeViewController.m
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "RepositoryNodeViewController.h"
#import "RepositoryNodeViewCell.h"
#import "UploadFormViewController.h"
#import "FileUtils.h"
#import "UITableView+LongPress.h"
#import "DownloadManager.h"
#import "LocalFileManager.h"
#import "DownloadInfo.h"
#import "DocumentViewController.h"
#import "AccountManager.h"
#import "PreviewCacheManager.h"
#import "MetadataViewController.h"

#import "CMISFolder.h"
#import "CMISPagedResult.h"
#import "CMISConstants.h"
#import "CMISRequest.h"
#import "CMISUtility.h"
#import "CMISSession.h"
#import "CMISOperationContext.h"

NSInteger const kDownloadFolderAlert = 1;
NSInteger const kConfirmMultipleDeletePrompt = 4;

//action sheet tags
static NSInteger const kAddActionSheetTag = 100;
static NSInteger const kUploadActionSheetTag = 101;
static NSInteger const kDeleteActionSheetTag = 103;
static NSInteger const kOperationActionSheetTag = 104;
static NSInteger const kDeleteFileAlert = 10;
static NSInteger const kRenameFileAlert = 11;

NSString * const kMultiSelectDownload = @"downloadAction";
NSString * const kMultiSelectDelete = @"deleteAction";
NSString * const kMultiSelectMove = @"moveAction";

static NSString * const kLoadMoreCellIdentifier = @"LoadMoreCellIdentifier";

@interface RepositoryNodeViewController () {
    NSMutableArray *itemsToDelete_;
    NSMutableArray *itemsToMove_;
}
@property (nonatomic, strong) CustomTableViewCell *loadMoreCell;
@property (nonatomic, strong) CMISRequest   *currentPreviewRequest;
@end

@implementation RepositoryNodeViewController
@synthesize moveQueueProgressBar = _moveQueueProgressBar;
@synthesize folderItems = _folderItems;
@synthesize pagedFolders = _pagedFolders;

@synthesize loadMoreCell = _loadMoreCell;

- (void) dealloc {
    if (self.popover) {
        [self dismissPopover];
        self.popover.delegate = nil;
    }
    if (self.actionSheet) {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
        self.actionSheet.delegate = nil;
    }
    [self setEditing:NO];
    [self cancelPreview];
    [self.multiSelectToolbar removeFromSuperview];
}

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
    
    [[self navigationItem] setTitle:[self.folder name]];
    
    //set right bar items
    [self loadRightBarItem];
    
    //Add long press for tableview cell
    [self.tableView addLongPressRecognizer];
    
    //register table cell class
    [self.tableView registerNib:[UINib nibWithNibName:@"RepositoryNodeViewCell" bundle:nil] forCellReuseIdentifier:kRepositoryNodeCellIdentifier];
    
    // Multi-select toolbar
    [self setMultiSelectToolbar:[[MultiSelectActionsToolbar alloc] initWithParentViewController:self]];
    [self.multiSelectToolbar setMultiSelectDelegate:self];
    [self.multiSelectToolbar addActionButtonNamed:kMultiSelectDownload withLabelKey:@"multiselect.button.download" atIndex:0];
    [self.multiSelectToolbar addActionButtonNamed:kMultiSelectDelete withLabelKey:@"multiselect.button.delete" atIndex:1];
    [self.multiSelectToolbar addActionButtonNamed:kMultiSelectMove withLabelKey:@"multiselect.button.move" atIndex:2];
    
    _loadMoreCell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [_loadMoreCell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [_loadMoreCell.textLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [_loadMoreCell.textLabel setText:NSLocalizedString(@"load.more.cell.title", @"Load More...")];
    [_loadMoreCell setShouldIndentWhileEditing:YES];
    
    [self savePagedResult:_pagedFolders];
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
    if (self.folderItems) {
        if (_pagedFolders.hasMoreItems) {
            return [self.folderItems count] + 1;
        }
        return [self.folderItems count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.folderItems count]) {
        RepositoryNodeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepositoryNodeCellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        CMISObject *fileObj = [self.folderItems objectAtIndex:[indexPath row]];
        
        cell.lblFileName.text = [fileObj name];
        cell.lblDetails.text = formatDocumentDateFromDate([fileObj lastModificationDate]);
        if ([fileObj.objectType isEqualToCaseInsensitiveString:kCMISPropertyObjectTypeIdValueFolder]) {
            [cell.imgIcon setImage:[UIImage imageNamed:@"folder"]];
        }else {
            [cell.imgIcon setImage:imageForFilename([fileObj name])];
        }
        
        return cell;
    }else {
        return _loadMoreCell;
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.folderItems count]) {
        CMISObject *fileObj = [self.folderItems objectAtIndex:[indexPath row]];
        
        if ([tableView isEditing]) {
            [self.multiSelectToolbar userDidSelectItem:fileObj atIndexPath:indexPath];
        }else {
            if ([fileObj.objectType isEqualToCaseInsensitiveString:kCMISPropertyObjectTypeIdValueFolder]) {
                [self loadFolderChildren:(CMISFolder*)fileObj];
            }else {
                //Preview Document
                [self previewItem:fileObj];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }else if(![tableView isEditing]) {  //don't load more items when editing
        [self loadMoreItems];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.folderItems count]) {
        CMISObject *fileObj = [self.folderItems objectAtIndex:[indexPath row]];
        
        if ([tableView isEditing]) {
            [self.multiSelectToolbar userDidDeselectItem:fileObj atIndexPath:indexPath];
        }
    }
}

- (void) loadFolderChildren:(CMISFolder*) folder {
    [self startHUD];
    [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult* results, NSError *error) {
        [self stopHUD];
        if (error) {
            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
        }else {
            if (IS_IPAD)
            {
                [IpadSupport clearDetailController];
            }
            RepositoryNodeViewController *repoNodeController = [[RepositoryNodeViewController alloc] initWithStyle:UITableViewStylePlain];
            [repoNodeController setFolder:folder];
            [repoNodeController setPagedFolders:results];
            [repoNodeController setSelectedAccountUUID:self.selectedAccountUUID];
            [repoNodeController setRepositoryIdentifier:[self repositoryIdentifier]];
            [self.navigationController pushViewController:repoNodeController animated:YES];
        }
    }];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"accessoryButtonTappedForRowWithIndexPath:%ld", (long)indexPath.row);
    RepositoryNodeViewCell * cell = (RepositoryNodeViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    CMISObject *fileObj = [[self.pagedFolders resultArray] objectAtIndex:[indexPath row]];
    if (cell.isDownloadingPreview) { //cancel preview
        [self cancelPreview];
    }else { //display item metadata
        //[self showMetadata:fileObj];
        CMISOperationContext *opContext = [CMISOperationContext defaultOperationContext];
        opContext.renditionFilterString = @"cmis:thumbnail";
        [self startHUD];
        [fileObj.session retrieveObject:fileObj.identifier operationContext:opContext completionBlock:^(CMISObject *object, NSError *error) {
            [self stopHUD];
            if (object) {
                [self showMetadata:object];
            }else {  //TODO: show error message
//                SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
//                                                                    inView:activeView()
//                                                                   message:[NSString stringWithFormat:@"%@ %@", _cmisObject.name, NSLocalizedString(@"dwonload.ismanaged", @"Retire object failed.")]
//                                                                     title:@""];
//                notice.displayTime = 3.0;
//                [notice show];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didRecognizeLongPressOnRowAtIndexPath:(NSIndexPath *)indexPath {
    RepositoryNodeViewCell * cell = (RepositoryNodeViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    CMISObject *fileObj = [[self.pagedFolders resultArray] objectAtIndex:[indexPath row]];
    
    [self showOperationMenu:fileObj withCell:cell];
    
}

#pragma mark -
#pragma mark UIRefreshControl Handler
- (void)refresh:(id)sender {
    [super refresh:sender];
    [self.folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult* results, NSError *error) {
        if (error) {
            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
            [CMISUtility handleCMISRequestError:error];
        }else {
            _folderItems = nil;
            [self savePagedResult:results];
        }
        [self endRefreshing];
    }];
}

- (void)reloadDataSource {
    [self startHUD];
    [self.folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult* results, NSError *error) {
        if (error) {
            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
            [CMISUtility handleCMISRequestError:error];
        }else {
            _folderItems = nil;
            [self savePagedResult:results];
        }
        [self stopHUD];
        [self.tableView reloadData];
    }];
}

- (void) loadMoreItems {
    if (!self.pagedFolders.hasMoreItems) {
        return;
    }
    [self startHUD];
    [self.pagedFolders fetchNextPageWithCompletionBlock:^(CMISPagedResult* results, NSError *error) {
        [self stopHUD];
        if (error) {
            ODSLogError(@"fetchNextPageWithCompletionBlock:%@", error);
        }else {
            [self savePagedResult:results];
        }
    }];
}

- (void) savePagedResult:(CMISPagedResult*) pagedResults {
    if (self.folderItems == nil) {
        self.folderItems = [NSMutableArray array];
    }
    
    if (userPrefShowHiddenFiles()) {
        [self.folderItems addObjectsFromArray:pagedResults.resultArray];
    }else {
        for (CMISObject *item in pagedResults.resultArray) {
            if ([item.name hasPrefix:@"."]) {
                continue;
            }
            [self.folderItems addObject:item];
        }
    }
    _pagedFolders = pagedResults;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Document Actions

//set right bar item
- (void) loadRightBarItem {
    
    NSMutableArray *rightBarButtons = [NSMutableArray array];
    
    
    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(processEditButtonAction:)];
    
    BOOL showAddButton = isAllowAction(self.folder, CMISActionCanCreateFolder) || isAllowAction(self.folder, CMISActionCanCreateDocument);
    
    [rightBarButtons addObject:editBarItem];
    
    if (showAddButton) {
        UIBarButtonItem *addBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(processAddButtonAction:event:)];
        self.actionSheetSenderControl = addBarItem;
        [rightBarButtons addObject:addBarItem];
    }
    
    //button position: -add --- edit-
    [self.navigationItem setRightBarButtonItems:rightBarButtons];
    
}

//process add button
- (void) processAddButtonAction:(id) sender event:(UIEvent *)event {
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@""
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:nil
                            otherButtonTitles: nil];
    
    if (isAllowAction(self.folder, CMISActionCanCreateFolder)) {
        [sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.create-folder", @"Create Folder")];
    }
    
    if (isAllowAction(self.folder, CMISActionCanCreateDocument)) {
        NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        BOOL hasCamera = [sourceTypes containsObject:(NSString *) kUTTypeImage];
        BOOL canCaptureVideo = [sourceTypes containsObject:(NSString *) kUTTypeMovie];
        
        [sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.upload", @"Upload")];
        
		if (hasCamera && canCaptureVideo)
        {
            [sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.take-photo-video", @"Take Photo or Video")];
		}
        else if (hasCamera)
        {
			[sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.take-photo", @"Take Photo")];
        }
        
        [sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.record-audio", @"Record Audio")];
    }
    
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.cancel", @"Cancel")]];
    
    [sheet setTag:kAddActionSheetTag];
    [self setActionSheet:sheet];
    
    if (IS_IPAD)
    {
        [self setActionSheetSenderControl:sender];
        [sheet setActionSheetStyle:UIActionSheetStyleDefault];
        
        UIBarButtonItem *actionButton = (UIBarButtonItem *)sender;
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            [sheet showFromBarButtonItem:sender animated:YES];
        }
        else
        {
            // iOS 5.1 bug workaround
            CGRect actionButtonRect = [(UIView *)[event.allTouches.anyObject view] frame];
            self.actionSheetSenderRect = actionButtonRect;
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
                CGRect screen = [[UIScreen mainScreen] bounds];
                actionButtonRect.origin.x = screen.size.width - (actionButtonRect.origin.x + actionButtonRect.size.width);
                actionButtonRect.origin.y = screen.size.height - (actionButtonRect.origin.y + actionButtonRect.size.height + 25.0);
            }
            [sheet showFromRect:actionButtonRect inView:self.view.window animated:YES];
        }
        [actionButton setEnabled:NO];
    }
    else
    {
        [sheet showInView:[[self tabBarController] view]];
    }
}

//process edit button
- (void) processEditButtonAction:(id) sender {
    if (self.actionSheet.window)
    {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
    }
    
    [self setEditing:YES];
}

- (void)performEditingDoneAction:(id)sender
{
    [self setEditing:NO];
}

- (void)loadRightBarForEditMode:(BOOL)animated
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self
                                                                                 action:@selector(performEditingDoneAction:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:doneButton] animated:animated];
}

- (void)processAddActionSheetWithButtonTitle:(NSString *)buttonLabel
{
    if ([buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.take-photo", @"Take Photo")] || [buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.take-photo-video", @"Take Photo or Video")])
    {
        if (!self.imagePickerController)
        {
            self.imagePickerController = [[UIImagePickerController alloc] init];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (IS_IPAD)
            {
                UIViewController *pickerContainer = [[UIViewController alloc] init];
                
                [pickerContainer setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
                [self.imagePickerController setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType]];
                [self.imagePickerController setDelegate:self];
                [pickerContainer.view addSubview:self.imagePickerController.view];
                
                [self presentModalViewControllerHelper:pickerContainer];
                [self.popover setPopoverContentSize:self.imagePickerController.view.frame.size animated:YES];
                [self.popover setPassthroughViews:[NSArray arrayWithObjects:[[UIApplication sharedApplication] keyWindow], self.imagePickerController.view, nil]];
                
                CGRect rect = self.popover.contentViewController.view.frame;
                self.imagePickerController.view.frame = rect;
                NSLog(@"frame=====%f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);            
            }
            else
            {
                
                [self.imagePickerController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
                [self.imagePickerController setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType]];
                [self.imagePickerController setDelegate:self];
                
                [self presentModalViewControllerHelper:self.imagePickerController];
            }
        });
    }
    else if ([buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.create-folder", @"Create Folder")])
    {
        CreateFolderViewController *createFolder = [[CreateFolderViewController alloc] initWithStyle:UITableViewStyleGrouped];
        createFolder.parentFolder = self.folder;
        createFolder.delegate = self;
        [createFolder setModalPresentationStyle:UIModalPresentationFormSheet];
        dispatch_async(dispatch_get_main_queue(), ^{
            [IpadSupport presentModalViewController:createFolder withNavigation:self.navigationController];
        });
    }
    else if([buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.record-audio", @"Record Audio")])
    {
        UploadInfo *uploadInfo = [[UploadInfo alloc] init];
        [uploadInfo setUploadType:UploadFormTypeAudio];
        [self loadUploadSingleItemForm:uploadInfo];
    }
    else if ([buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.upload", @"Upload")])
    {
        dispatch_async(dispatch_get_main_queue(), ^ {
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@""
                                    delegate:self
                                    cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: NSLocalizedString(@"add.actionsheet.choose-photo", @"Choose Photo from Library"), NSLocalizedString(@"add.actionsheet.upload-document", @"Upload Document"), nil];
            
            [sheet setCancelButtonIndex:[sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.cancel", @"Cancel")]];
            if (IS_IPAD)
            {
                [sheet setActionSheetStyle:UIActionSheetStyleDefault];
                //[sheet showFromBarButtonItem:self.actionSheetSenderControl animated:YES];
                if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
                {
                    [sheet showFromBarButtonItem:self.actionSheetSenderControl animated:YES];
                }
                else
                {
                    // iOS 5.1 bug workaround
                    CGRect actionButtonRect = self.actionSheetSenderRect;
                    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
                        CGRect screen = [[UIScreen mainScreen] bounds];
                        actionButtonRect.origin.x = screen.size.width - (actionButtonRect.origin.x + actionButtonRect.size.width);
                        actionButtonRect.origin.y = screen.size.height - (actionButtonRect.origin.y + actionButtonRect.size.height + 25.0);
                    }
                    [sheet showFromRect:actionButtonRect inView:self.view.window animated:YES];
                }
            }
            else
            {
                [sheet showInView:[[self tabBarController] view]];
            }
            
            [sheet setTag:kUploadActionSheetTag];
            [self.actionSheetSenderControl setEnabled:NO];
            [self setActionSheet:sheet];
        });
    }
}

- (void)processUploadActionSheetWithButtonTitle:(NSString *)buttonLabel
{
    if ([buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.choose-photo", @"Choose Photo from Library")])
    {
        __block RepositoryNodeViewController *blockSelf = self;
        
        AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error)
        {
          ODSLogDebug(@"Fail. Error: %@", error);
          
          if (error == nil)
          {
              ODSLogDebug(@"User has cancelled.");
              [blockSelf dismissModalViewControllerHelper];
          }
          else
          {
              // We need to wait for the view controller to appear first.
              double delayInSeconds = 0.5;
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                  [blockSelf dismissModalViewControllerHelper:NO];
                  //Fallback in the UIIMagePickerController if the AssetsLibrary is not accessible
                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                  [picker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                  [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                  [picker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType]];
                  [picker setDelegate:blockSelf];
                  
                  [blockSelf presentModalViewControllerHelper:picker animated:NO];
                  
              });
          }
          
        } andSuccessBlock:^(NSArray *info) {
          [blockSelf startHUD];
          ODSLogDebug(@"User finished picking %d library assets", info.count);
          //It is always NO because we will show the UploadForm next
          //Only affects iPhone, in the iPad the popover dismiss is always animated
          [blockSelf dismissModalViewControllerHelper:NO];
          
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              if([info count] == 1)
              {
                  ALAsset *asset = [info lastObject];
                  UploadInfo *uploadInfo = [blockSelf uploadInfoFromAsset:asset];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [blockSelf loadUploadSingleItemForm:uploadInfo];
                      [blockSelf stopHUD];
                  });
              } 
              else if([info count] > 1)
              {
                  NSMutableArray *uploadItems = [NSMutableArray arrayWithCapacity:[info count]];
                  for (ALAsset *asset in info)
                  {
                      @autoreleasepool
                      {
                          UploadInfo *uploadInfo = [blockSelf uploadInfoFromAsset:asset];
                          [uploadItems addObject:uploadInfo];
                      }
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [blockSelf loadUploadMultiItemsForm:uploadItems andUploadType:UploadFormTypeLibrary];
                      [blockSelf stopHUD];
                  });
              }
          });
          
        }];
        
        [imagePickerController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentModalViewControllerHelper:imagePickerController];
        });
    }
    else if([buttonLabel isEqualToString:NSLocalizedString(@"add.actionsheet.upload-document", @"Upload Document from Saved Docs")]) 
    {
        SavedDocumentPickerController *picker = [[SavedDocumentPickerController alloc] initWithMultiSelection:YES];
        [picker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [picker setDelegate:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentModalViewControllerHelper:picker];
        });
    }
}

- (void)processOperationsActionSheetWithButtonTitle:(NSString *)buttonLabel
{
    if ([buttonLabel isEqualToString:NSLocalizedString(@"operation.pop.menu.delete", @"Delete")])
    {
        [self showDeleteItemPrompt];
    }
    else if ([buttonLabel isEqualToString:NSLocalizedString(@"operation.pop.menu.rename", @"Rename")])
    {
        [self showRenameItemPrompt];
    }
   else if ([buttonLabel isEqualToString:NSLocalizedString(@"operation.pop.menu.move", @"Move")])
    {
        itemsToMove_ = [[NSMutableArray alloc] initWithObjects:_selectedItem, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showChooseMoveTarget];
        });
    }
    else if ([buttonLabel isEqualToString:NSLocalizedString(@"operation.pop.menu.download", @"Download")]){
        if (_selectedItem) {
            //check if the file have already downloaded
            if (isFileDownloaded(_selectedItem)) {
                NSString *downloadMessage  = [NSString stringWithFormat:@"%@ %@", [_selectedItem name], NSLocalizedString(@"dwonload.ismanaged", @"have already downloaded.")];
                SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
                                                                    inView:activeView()
                                                                   message:downloadMessage
                                                                     title:@""];
                notice.displayTime = 3.0;
                [notice show];
            }else {
                NSString *downloadMessage  = [NSString stringWithFormat:@"%@ %@", [_selectedItem name], NSLocalizedString(@"download.progress.starting", @"Download starting...")];
                SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
                                                                    inView:activeView()
                                                                   message:downloadMessage
                                                                     title:@""];
                notice.displayTime = 3.0;
                [notice show];
                [[DownloadManager sharedManager] queueRepositoryItems:[NSArray arrayWithObject:_selectedItem] withAccountUUID:self.selectedAccountUUID withRepositoryID:self.repositoryIdentifier andTenantId:nil];
            }
        }
    }
    else if ([buttonLabel isEqualToString:NSLocalizedString(@"operation.pop.menu.createlink", @"Create Download Link")]) {
        if (_selectedItem) {
            CreateLinkViewController *createLinkController = [[CreateLinkViewController alloc] initWithRepositoryItem:_selectedItem parentItem:self.folder accountUUID:self.selectedAccountUUID];
            
            createLinkController.delegate = self;
            createLinkController.viewTitle = NSLocalizedString(@"create-link.view.title", @"Create Link");
            if (IS_IPAD) {
                [createLinkController setModalPresentationStyle:UIModalPresentationFormSheet];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [IpadSupport presentModalViewController:createLinkController withNavigation:self.navigationController];
            });
        }
    }
}

- (void)processDeleteActionSheetWithButtonTitle:(NSString *)buttonLabel
{
    if ([buttonLabel isEqualToString:NSLocalizedString(@"delete.confirmation.button", @"Delete")])
    {
        [self didConfirmMultipleDelete];
    }
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // Multi-select: we toggle this here to maintain the swipe-to-delete ability
    [self.tableView setAllowsMultipleSelectionDuringEditing:editing];
    [self.tableView setEditing:editing animated:YES];
    
//    if([self.navigationController isKindOfClass:[DocumentsNavigationController class]])
//    {
//        DocumentsNavigationController *navController = (DocumentsNavigationController *)[self navigationController];
//        editing ? [navController hidePanels] : [navController showPanels];
//    }
    
    if (editing)
    {
        [_loadMoreCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.multiSelectToolbar didEnterMultiSelectMode];
        [self loadRightBarForEditMode:YES];
        [[self refreshControl] removeFromSuperview];
    }
    else
    {
        [_loadMoreCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        [self.multiSelectToolbar didLeaveMultiSelectMode];
        [self loadRightBarItem];
        [self.view addSubview:[self refreshControl]];
    }
    
}

- (void) presentModalViewControllerHelper:(UIViewController *)modalViewController
{
    [self presentModalViewControllerHelper:modalViewController animated:YES];
}

- (void)presentModalViewControllerHelper:(UIViewController *)modalViewController animated:(BOOL)animated
{
    if (IS_IPAD && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) //to fix ios6 cann't display Image Picker Controller without UIPopoverController
    {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:modalViewController];
        [self setPopover:popoverController];
        
        UIView *actionSheetSenderControlView = [self.actionSheetSenderControl valueForKey:@"view"];
        
        if(actionSheetSenderControlView.window != nil)
        {
            [self.popover presentPopoverFromBarButtonItem:self.actionSheetSenderControl
                                 permittedArrowDirections:UIPopoverArrowDirectionUp animated:animated];
        }
    } else  {
        [[self navigationController] presentModalViewController:modalViewController animated:animated];
    }
}

- (void)dismissModalViewControllerHelper
{
    [self dismissModalViewControllerHelper:YES];
}

- (void)dismissModalViewControllerHelper:(BOOL)animated
{
    [self dismissModalViewControllerAnimated:animated];
}

- (void)dismissPopover
{
    if ([self.popover isPopoverVisible])
    {
        [self.popover dismissPopoverAnimated:YES];
        [self setPopover:nil];
    }
}

#pragma mark -
#pragma mark Present Upload Form

- (void) loadUploadMultiItemsForm:(NSArray*) infos andUploadType:(UploadFormType) uploadType {
    UploadFormViewController *uploadFormController = [[UploadFormViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [uploadFormController setUploadType:uploadType];
    [uploadFormController setSelectedAccountUUID:self.selectedAccountUUID];
    [uploadFormController setMultiUploadItems:infos];
    [uploadFormController setModalPresentationStyle:UIModalPresentationFormSheet];
    [uploadFormController createUploadMultiItemsForm:infos uploadType:uploadType];
    
    //to fix issue: http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8
    dispatch_async(dispatch_get_main_queue(), ^ {
        [IpadSupport presentModalViewController:uploadFormController withNavigation:self.navigationController];
    });

}

- (void) loadUploadSingleItemForm:(UploadInfo*) uploadInfo {
    UploadFormViewController *uploadFormController = [[UploadFormViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [uploadFormController setSelectedAccountUUID:self.selectedAccountUUID];
    [uploadFormController createUpoadSingleItemForm:uploadInfo uploadType:uploadInfo.uploadType];
    [uploadFormController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [uploadInfo setSelectedAccountUUID:[self selectedAccountUUID]];
    [uploadInfo setFolderName:[self.folder name]];
    [uploadInfo setTargetFolderIdentifier:[self.folder identifier]];
    [uploadInfo setRepositoryIdentifier:[self repositoryIdentifier]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [IpadSupport presentModalViewController:uploadFormController withNavigation:self.navigationController];
    });
}

- (UploadInfo*) uploadInfoFromAsset:(ALAsset*) asset {
    UploadInfo *uploadInfo = [[UploadInfo alloc] init];
    NSURL *previewURL = [asset valueForProperty:ALAssetPropertyAssetURL];//[[asset defaultRepresentation] url];
    [uploadInfo setUploadFileURL:previewURL];
    
    NSLog(@"pick image:%@ --- %@", [ asset valueForProperty:ALAssetPropertyAssetURL], [[asset defaultRepresentation] url]);
    
    if(isVideoExtension([previewURL pathExtension]))
    {
        [uploadInfo setUploadType:UploadFormTypeVideo];
    }
    else
    {
        [uploadInfo setUploadType:UploadFormTypePhoto];
    }
    
    //Setting the name with the original name the photo/video was taken
    [uploadInfo setFilename:[[[asset defaultRepresentation] filename] stringByDeletingPathExtension]];
    [uploadInfo setExtension:[[[asset defaultRepresentation] filename] pathExtension]];
    
    [uploadInfo setUploadFileURL:previewURL];
    [uploadInfo setSelectedAccountUUID:[self selectedAccountUUID]];
    [uploadInfo setFolderName:[self.folder name]];
    [uploadInfo setTargetFolderIdentifier:[self.folder identifier]];
    [uploadInfo setRepositoryIdentifier:[self repositoryIdentifier]];
    
    return uploadInfo;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    BOOL mediaHasJustBeenCaptured = picker.sourceType == UIImagePickerControllerSourceTypeCamera;
    NSURL *mediaURL = [info objectForKey:UIImagePickerControllerReferenceURL];  //UIImagePickerControllerMediaURL
    if (mediaURL == nil) {
        mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
    }
    [self dismissModalViewControllerHelper:NO];
    
    ODSLogDebug(@"Image picked from Photo Library with Location Services off/unavailable:%@ --- %@",mediaURL, [info objectForKey:UIImagePickerControllerMediaURL]);
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        if (mediaHasJustBeenCaptured) {
            [self startHUD];
            [self setPhotoSaver:[[PhotoCaptureSaver alloc] initWithPickerInfo:info andDelegate:self]];
            [self.photoSaver startSavingImage];
        }else {
            UploadInfo *uploadInfo = [[UploadInfo alloc] init];
            [uploadInfo setUploadFileURL:mediaURL];
            [uploadInfo setUploadType:UploadFormTypePhoto];
            
            //present upload photo from
            [self loadUploadSingleItemForm:uploadInfo];
        }
        
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] || [mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        UploadInfo *videoUpload = [[UploadInfo alloc] init];
        [videoUpload setUploadFileURL:mediaURL];
        [videoUpload setUploadType:UploadFormTypeVideo];
        [videoUpload setFilename:[mediaURL lastPathComponent]];
        
       //present upload video from
        [self loadUploadSingleItemForm:videoUpload];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerHelper:YES];
}

#pragma mark - Photo Capture Saver
- (void)photoCaptureSaver:(PhotoCaptureSaver *)photoSaver didFinishSavingWithAssetURL:(NSURL *)assetURL
{
    ALAsset *asset = assetFromURL(assetURL);
    if (asset) {
        UploadInfo *uploadInfo = [[UploadInfo alloc] init];
        [uploadInfo setUploadFileURL:assetURL];
        [uploadInfo setUploadType:UploadFormTypePhoto];
        [uploadInfo setFilename:[[asset defaultRepresentation] filename]];
        
        //present upload photo from
        [self loadUploadSingleItemForm:uploadInfo];
    }
    [self stopHUD];
}

//This will be called when location services are not enabled
- (void)photoCaptureSaver:(PhotoCaptureSaver *)photoSaver didFinishSavingWithURL:(NSURL *)imageURL
{
    
    UploadInfo *uploadInfo = [[UploadInfo alloc] init];
    [uploadInfo setUploadFileURL:imageURL];
    [uploadInfo setUploadType:UploadFormTypePhoto];
    [uploadInfo setUploadFileIsTemporary:YES];
    
    //present upload photo from
    [self loadUploadSingleItemForm:uploadInfo];
    
    [self stopHUD];
}

- (void)photoCaptureSaver:(PhotoCaptureSaver *)photoSaver didFailWithError:(NSError *)error
{
    [self stopHUD];
    displayErrorMessageWithTitle(NSLocalizedString(@"browse.capturephoto.failed.message", @"Photo capture failed alert message"), NSLocalizedString(@"browse.capturephoto.failed.title", @"Photo capture failed alert title"));
}

#pragma mark -
#pragma mark Create Folder Delegate

- (void)createFolder:(CreateFolderViewController *)createFolder succeededForName:(NSString *)folderName {
    displayInformationMessage([NSString stringWithFormat:NSLocalizedString(@"create-folder.success", @"Created folder"), folderName]);
    [self reloadDataSource];
}

#pragma mark -
#pragma mark Create Link Delegate medthods

- (void)createLink:(CreateLinkViewController *)createLink succeededForName:(NSString *)linkName {
    displayInformationMessage(NSLocalizedString(@"create-link.success", @"Created link"));
}

- (void)createLink:(CreateLinkViewController *)createLink failedForName:(NSString *)linkName {
    displayErrorMessage(NSLocalizedString(@"create-link.failure", @"Failed to create link"));
}

#pragma mark - SavedDocumentPickerDelegate

- (void)savedDocumentPicker:(SavedDocumentPickerController *)picker didPickDocuments:(NSArray *)documents {
    ODSLogDebug(@"User selected the documents %@", documents);
    
    //Hide popover on iPad
    [self dismissModalViewControllerHelper:NO];
    
    if([documents count] == 1)
    {
        LocalDocument *doc = [documents lastObject];
        NSURL *documentURL = [NSURL URLWithString:doc.documentURL];
        UploadInfo *uploadInfo = [[UploadInfo alloc] init];
        [uploadInfo setUploadFileURL:documentURL];
        [uploadInfo setUploadType:UploadFormTypeDocument];
        [uploadInfo setFilename:[doc docName]];
        [uploadInfo setSelectedAccountUUID:[self selectedAccountUUID]];
        [uploadInfo setFolderName:[self.folder name]];
        [uploadInfo setTargetFolderIdentifier:[self.folder identifier]];
        [uploadInfo setRepositoryIdentifier:[self repositoryIdentifier]];
        [uploadInfo setExtension:[[doc docName] pathExtension]];
        [self loadUploadSingleItemForm:uploadInfo];
    }
    else if([documents count] > 1)
    {
        NSMutableArray *uploadItems = [NSMutableArray arrayWithCapacity:[documents count]];
        for(LocalDocument *doc in documents)
        {
            UploadInfo *uploadInfo = [[UploadInfo alloc] init];
            [uploadInfo setUploadFileURL:[NSURL URLWithString:doc.documentURL]];
            [uploadInfo setUploadType:UploadFormTypeDocument];
            [uploadInfo setFilename:[doc docName]];
            [uploadInfo setSelectedAccountUUID:[self selectedAccountUUID]];
            [uploadInfo setFolderName:[self.folder name]];
            [uploadInfo setTargetFolderIdentifier:[self.folder identifier]];
            [uploadInfo setRepositoryIdentifier:[self repositoryIdentifier]];
            [uploadInfo setExtension:[[doc docName] pathExtension]];
            [uploadItems addObject:uploadInfo];
        }
        
        [self loadUploadMultiItemsForm:uploadItems andUploadType:UploadFormTypeMultipleDocuments];
    }
}

- (void)savedDocumentPickerDidCancel:(SavedDocumentPickerController *)picker
{
    [self dismissModalViewControllerHelper:YES];
}

#pragma mark -
#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonLabel = nil;
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.actionSheetSenderControl setEnabled:YES];
    [self setActionSheet:nil];
    
    if (buttonIndex > -1)
    {
        buttonLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
    
	if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        switch ([actionSheet tag])
        {
            case kAddActionSheetTag:
            [self processAddActionSheetWithButtonTitle:buttonLabel];
            break;
            case kUploadActionSheetTag:
            [self processUploadActionSheetWithButtonTitle:buttonLabel];
            break;
            case kDeleteActionSheetTag:
            [self processDeleteActionSheetWithButtonTitle:buttonLabel];
            break;
            case kOperationActionSheetTag:
            [self processOperationsActionSheetWithButtonTitle:buttonLabel];
            break;
            default:
            break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        [self.actionSheetSenderControl setEnabled:YES];
    }
}

#pragma mark - 
#pragma mark Long press actions for uitableview

- (void) showOperationMenu:(CMISObject* ) selectedItem withCell:(RepositoryNodeViewCell*) cell
{
    self.selectedItem = selectedItem;
    
    if (IS_IPAD)
    {
        [self dismissPopover];
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:NSLocalizedString(@"operation.pop.menu.title", @"Operations")
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:nil
                            otherButtonTitles: nil];
    
    
    if (isAllowAction(selectedItem, CMISActionCanDeleteObject)) {
        [sheet addButtonWithTitle:NSLocalizedString(@"operation.pop.menu.delete", @"Delete")];
    }
    
    if (isAllowAction(selectedItem, CMISActionCanUpdateProperties)) {
        [sheet addButtonWithTitle:NSLocalizedString(@"operation.pop.menu.rename", @"Rename")];
    }
    
    if (isAllowAction(selectedItem, CMISActionCanMoveObject)) {
        [sheet addButtonWithTitle:NSLocalizedString(@"operation.pop.menu.move", @"Move")];
    }
    
    if (!isCMISFolder(self.selectedItem)) {
        [sheet addButtonWithTitle:NSLocalizedString(@"operation.pop.menu.download", @"Download")];
    }
    //TODO:disable create download link feature.
    [sheet addButtonWithTitle:NSLocalizedString(@"operation.pop.menu.createlink", @"Create Downlaod Link")];
    
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.cancel", @"Cancel")]];
    
    if (IS_IPAD)
    {
        //[self setActionSheetSenderControl:sender];
        [sheet setActionSheetStyle:UIActionSheetStyleDefault];
        
        //UIBarButtonItem *actionButton = (UIBarButtonItem *)sender;
        
        CGRect actionButtonRect = cell.frame;
        actionButtonRect.size.height = actionButtonRect.size.height/2;
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            actionButtonRect.origin.y = 10;
            [sheet showFromRect:actionButtonRect inView:cell animated:YES];
        }
        else
        {
            // iOS 5.1 bug workaround
            actionButtonRect.origin.y += 70;
            [sheet showFromRect:actionButtonRect inView:self.view.window animated:YES];
            
        }
    }
    else
    {
        [sheet showInView:[[self tabBarController] view]];
    }
    
    [sheet setTag:kOperationActionSheetTag];
    [self setActionSheet:sheet];
}

#pragma mark  - Operations Prompt method

- (void)showDeleteItemPrompt
{
    if (_selectedItem) {
        NSString  *fileName = self.selectedItem.name;
        UIAlertView *deleteItemPrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm.delete.prompt.title", @"")
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"confirm.delete.prompt.message", @"Are you sure to delete file %@?"), fileName]
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"confirm.delete.prompt.cancel", @"Cancel")
                                                          otherButtonTitles:NSLocalizedString(@"confirm.delete.prompt.ok", @"Delete"), nil];
        [deleteItemPrompt setTag:kDeleteFileAlert];
        [deleteItemPrompt show];
    }
}

- (void) showRenameItemPrompt
{
    if (_selectedItem) {
        NSString  *fileName = self.selectedItem.name;;
        UIAlertView *renameItemPrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm.rename.prompt.title", @"")
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"confirm.rename.prompt.message", @"")]
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"confirm.rename.prompt.cancel", @"Cancel")
                                                          otherButtonTitles:NSLocalizedString(@"confirm.rename.prompt.ok", @"Ok"), nil];
        renameItemPrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *inputTextField = [renameItemPrompt textFieldAtIndex:0];
        inputTextField.text = fileName;
        
        [renameItemPrompt setTag:kRenameFileAlert];
        [renameItemPrompt show];
    }
}

- (void)showChooseMoveTarget
{
    ChooserFolderViewController *chooseFolder = [[ChooserFolderViewController alloc] initWithAccountUUID:self.selectedAccountUUID sourceFolder:self.folder selectedItems:itemsToMove_];
    AccountInfo *accountInfo = [[AccountManager sharedManager] accountInfoForUUID:self.selectedAccountUUID];
    chooseFolder.viewTitle = [accountInfo vendor];
    chooseFolder.itemType = kMoveTargetTypeRepo;
    chooseFolder.selectedDelegate = self;
    [chooseFolder setModalPresentationStyle:UIModalPresentationFormSheet];
    [IpadSupport presentModalViewController:chooseFolder withNavigation:self.navigationController];
}

- (void) showMetadata:(CMISObject*) item {
    MetadataViewController *metadataViewController = [[MetadataViewController alloc] initWithStyle:UITableViewStyleGrouped cmisObject:item accountUUID:self.selectedAccountUUID repositoryID:self.repositoryIdentifier];
    [IpadSupport pushDetailController:metadataViewController withNavigation:self.navigationController andSender:self];
}

#pragma mark - UIAlertView Delegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (IS_IPAD)
    {
        [self dismissPopover];
    }
    
    if (alertView.tag == kConfirmMultipleDeletePrompt)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [self didConfirmMultipleDelete];
        }
        [self setEditing:NO];
    }
    else if (alertView.tag == kDeleteFileAlert)
    {
        if (buttonIndex != alertView.cancelButtonIndex && _selectedItem)
        {
            self.deleteQueueProgressBar = [DeleteQueueProgressBar createWithItems:[NSArray arrayWithObjects:_selectedItem,nil] delegate:self andMessage:NSLocalizedString(@"Deleting Item", @"Deleting Item")];
            [self.deleteQueueProgressBar setSelectedUUID:self.selectedAccountUUID];
            [self.deleteQueueProgressBar startDeleting];
        }
        _selectedItem = nil;
    }
    else if (alertView.tag == kRenameFileAlert)
    {
        if (buttonIndex != alertView.cancelButtonIndex && _selectedItem)
        {
            UITextField *inputTextField = [alertView textFieldAtIndex:0];
            NSString  *fileName = self.selectedItem.name;
            NSString  *newFilename = inputTextField.text;
            if ((newFilename && [newFilename length] > 0) && ![fileName isEqualToString:newFilename]) {  //not nil and not equal to old file name
                [self renameItem:newFilename];
            }
        }
        _selectedItem = nil;
    }
    return;
}

#pragma mark - Delete objects

- (void)askDeleteConfirmationForMultipleItems
{
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"delete.confirmation.multiple.message", @"Are you sure you want to delete x items"), [itemsToDelete_ count]];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"cancelButton", @"Cancel")
                                          destructiveButtonTitle:NSLocalizedString(@"delete.confirmation.button", @"Delete")
                                               otherButtonTitles:nil];
    [sheet setTag:kDeleteActionSheetTag];
    [self setActionSheet:sheet];
    // Display on the tabBar in order to maintain device rotation
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)didConfirmMultipleDelete
{
    self.deleteQueueProgressBar = [DeleteQueueProgressBar createWithItems:itemsToDelete_ delegate:self andMessage:NSLocalizedString(@"Deleting Item", @"Deleting Item")];
    [self.deleteQueueProgressBar setSelectedUUID:self.selectedAccountUUID];
    [self.deleteQueueProgressBar startDeleting];
}


#pragma mark - DeleteQueueProgressBar Delegate Methods

- (void)deleteQueue:(DeleteQueueProgressBar *)deleteQueueProgressBar completedDeletes:(NSArray *)deletedItems
{
    for (CMISObject *item in deletedItems)
    {
        if (IS_IPAD && [item.identifier isEqualToString:[IpadSupport getCurrentDetailViewControllerObjectID]]) {
            
            [IpadSupport clearDetailController];
        }
    }
    
    [self reloadDataSource];
    
    [self setEditing:NO];
}

- (void)deleteQueueWasCancelled:(DeleteQueueProgressBar *)deleteQueueProgressBar
{
    self.deleteQueueProgressBar = nil;
    [self setEditing:NO];
}

#pragma mark - RenameQueueProgressBar Delegate Methods
- (void)moveQueue:(MoveQueueProgressBar *)moveQueueProgressBar completedMoves:(NSArray *)movedItems {
    
    for (CMISObject *item in movedItems)
    {
        if (IS_IPAD && [item.identifier isEqualToString:[IpadSupport getCurrentDetailViewControllerObjectID]]) {
            
            [IpadSupport clearDetailController];
        }
    }
    
    [self reloadDataSource];
    
    [self setEditing:NO];
}

- (void)moveQueueWasCancelled:(MoveQueueProgressBar *)moveQueueProgressBar {
    self.moveQueueProgressBar = nil;
    [self setEditing:NO];
}

#pragma mark - Rename File & Folder
- (void) renameItem:(NSString*) newFileName
{
    if (_selectedItem && newFileName) {
        self.renameQueueProgressBar = [RenameQueueProgressBar createWithItem:_selectedItem withNewName:newFileName delegate:self andMessage:NSLocalizedString(@"Rename.progressbar.message", @"Renaming Item")];
        [self.renameQueueProgressBar setSelectedUUID:self.selectedAccountUUID];
        [self.renameQueueProgressBar setTenantID:nil];
        [self.renameQueueProgressBar startRenaming];
    }
}

#pragma mark - RenameQueueProgressBar Delegate Methods

- (void)renameQueue:(RenameQueueProgressBar *)renameQueueProgressBar completedRename:(id)renamedItem
{
    CMISObject *item =  (CMISObject*) renamedItem;
    if (IS_IPAD && [item.identifier isEqualToString:[IpadSupport getCurrentDetailViewControllerObjectID]]) {
        
        [IpadSupport clearDetailController];
    }
    
    [self.tableView setAllowsMultipleSelectionDuringEditing:NO];
    [self.tableView setEditing:NO animated:YES];
    [self reloadDataSource];
}

- (void)renameQueueWasCancelled:(RenameQueueProgressBar *)renameQueueProgressBar
{
    self.renameQueueProgressBar = nil;
    [self setEditing:NO];
}

#pragma mark - Chooser Folder Delegate
- (void)selectedItem:(CMISObject *)selectedItem repositoryID:(NSString*) repoID{
    self.moveQueueProgressBar = [MoveQueueProgressBar createWithItems:itemsToMove_ targetFolder:selectedItem delegate:self andMessage:NSLocalizedString(@"Moving Item", @"Moving Item")];
    [self.moveQueueProgressBar setSelectedUUID:self.selectedAccountUUID];
    [self.moveQueueProgressBar setTenantID:nil];
    [self.moveQueueProgressBar setSourceFolderId:self.folder.identifier];
    [self.moveQueueProgressBar startMoving];
}

#pragma mark - MultiSelectActionsDelegate Methods

- (void)multiSelectItemsDidChange:(MultiSelectActionsToolbar *)msaToolbar items:(NSArray *)selectedItems
{
    BOOL downloadActionIsViable = ([selectedItems count] > 0);
    BOOL deleteActionIsViable = ([selectedItems count] > 0);
    BOOL moveActionIsViable = ([selectedItems count] > 0);
    
    for (CMISObject *item in selectedItems)
    {
        if (isCMISFolder(item))
        {
            downloadActionIsViable = NO;
        }
        
        if (!isAllowAction(item, CMISActionCanDeleteObject))
        {
            deleteActionIsViable = NO;
        }
        
        if (!isAllowAction(item, CMISActionCanMoveObject)) {
            moveActionIsViable = NO; //TODO:a object can be deleted, it should be moved.
        }
    }
    
    [self.multiSelectToolbar enableActionButtonNamed:kMultiSelectDownload isEnabled:downloadActionIsViable];
    [self.multiSelectToolbar enableActionButtonNamed:kMultiSelectDelete isEnabled:deleteActionIsViable];
    [self.multiSelectToolbar enableActionButtonNamed:kMultiSelectMove isEnabled:moveActionIsViable];
}

- (void)multiSelectUserDidPerformAction:(MultiSelectActionsToolbar *)msaToolbar named:(NSString *)name withItems:(NSArray *)selectedItems atIndexPaths:(NSArray *)selectedIndexPaths
{
    if ([name isEqual:kMultiSelectDownload])
    {
        NSString *downloadMessage = nil;
        NSMutableArray *itemToDownload = [NSMutableArray array];
        
        for (CMISObject *item in selectedItems) {
            if (!isFileDownloaded(item)) {
                [itemToDownload addObject:item];
            }
        }
        if ([itemToDownload count] == 0) {
            downloadMessage  = NSLocalizedString(@"dwonload.selected.items.ismanaged", @"All selected items have already downloaded.");
        }else if ([itemToDownload count] == 1) {
            CMISObject *item = [selectedItems objectAtIndex:0];
            downloadMessage = [NSString stringWithFormat:@"%@ %@", [item name], NSLocalizedString(@"download.progress.starting", @"Download starting...")];
        }else {
            downloadMessage = [NSString stringWithFormat:@"%lu %@", (unsigned long)[selectedItems count], NSLocalizedString(@"download.progress.files.starting", @"files Download starting...")];
        }
        
        SystemNotice *notice = [SystemNotice systemNoticeWithStyle:SystemNoticeStyleInformation
                                                            inView:activeView()
                                                           message:downloadMessage
                                                             title:@""];
        notice.displayTime = 3.0;
        [notice show];
        
        if ([itemToDownload count] > 0) {
            [[DownloadManager sharedManager] queueRepositoryItems:itemToDownload withAccountUUID:self.selectedAccountUUID withRepositoryID:self.repositoryIdentifier andTenantId:nil];
        }
        [self setEditing:NO];
    }
    else if ([name isEqual:kMultiSelectDelete])
    {
        itemsToDelete_ = nil;
        itemsToDelete_ = [selectedItems copy];
        [self askDeleteConfirmationForMultipleItems];
    }
    else if ([name isEqualToString:kMultiSelectMove])
    {
        itemsToMove_ = nil;
        itemsToMove_ = [selectedItems copy];
        [self showChooseMoveTarget];
    }
}

#pragma mark -
#pragma Preview Manager
- (void) previewItem:(CMISObject*) item {
    [self cancelPreview];
    LocalFileManager *downloadManager = [LocalFileManager sharedInstance];
    PreviewCacheManager *previewManager = [PreviewCacheManager sharedManager];
    NSDictionary *previewInfo = [previewManager downloadInfoFromCache:item];
    NSString *fileKey = [LocalFileManager downloadKeyWithObject:item];//
    if ([downloadManager downloadExistsForKey:fileKey]) {   //use downloaded data
        [self showDocument:item withPath:[FileUtils pathToSavedFile:fileKey]];
    }else if ([previewManager previewFileExists:item] && previewInfo) {
        [self showDocument:item withPath:[previewManager generateCachePath:item]];
    }else {
        [self.tableView setAllowsSelection:NO];
        //We fetch the current repository items from the DataSource
        [self dwonlaodPreviewItem:item];
    }
}

// Cancel current preview request
- (void) cancelPreview {
    if (self.currentPreviewRequest) {
        [self.currentPreviewRequest cancel];
        self.currentPreviewRequest = nil;
    }
}

// download preview file
- (void) dwonlaodPreviewItem:(CMISObject*) item {
    [self downloadPreviewFileStarted:item];
    CMISSessionParameters *params = [CMISUtility sessionParametersWithAccount:[self selectedAccountUUID] withRepoIdentifier:[self repositoryIdentifier]];
    self.currentPreviewRequest = [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *session, NSError *sessionError) {
        if (session == nil) {
            ODSLogError(@"%@", sessionError);
            [self downlaodPreviewFileFailed:sessionError withItem:item];
        }else {
            PreviewCacheManager *previewManager = [PreviewCacheManager sharedManager];
            self.currentPreviewRequest = [session downloadContentOfCMISObject:[item identifier] toFile:[previewManager generateTempPath:item]
                                                       completionBlock:^(NSError *error){
                                                           if (error) {
                                                               ODSLogError(@"%@", error);
                                                               [self downlaodPreviewFileFailed:error withItem:item];
                                                           }else {
                                                               [self downloadPreviewFileFinished:item];
                                                           }
                                                       } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal){
                                                           NSDictionary *progressInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:bytesDownloaded], @"DownloadedBytes", [NSNumber numberWithLongLong:bytesTotal], @"TotalBytes", item, @"Item", nil];
                                                           [self performSelectorInBackground:@selector(updatePreviewDownloadProgress:) withObject:progressInfo];
                                                       }];
        }
    }];
}

- (void) downlaodPreviewFileFailed:(NSError*) error withItem:(CMISObject*) item{
    NSIndexPath *indexPath = [self getIndexPathForItem:item];
    RepositoryNodeViewCell *cell = (RepositoryNodeViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.progressBar setProgress:0.0f];
    [cell.progressBar setHidden:YES];
    [cell.lblDetails setHidden:NO];
    [cell setIsDownloadingPreview:NO];
    self.currentPreviewRequest = nil;
    [self.tableView setAllowsSelection:YES];
}

- (void) downloadPreviewFileFinished:(CMISObject*) item {
    NSIndexPath *indexPath = [self getIndexPathForItem:item];
    RepositoryNodeViewCell *cell = (RepositoryNodeViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.progressBar setProgress:0.0f];
    [cell.progressBar setHidden:YES];
    [cell.lblDetails setHidden:NO];
    [cell setIsDownloadingPreview:NO];
    
    //cache file
    PreviewCacheManager *previewManager = [PreviewCacheManager sharedManager];
    DownloadInfo *downloadInfo = [[DownloadInfo alloc] initWithRepositoryItem:item withAcctUUID:self.selectedAccountUUID withRepositoryID:self.repositoryIdentifier withTenantID:nil];
    [downloadInfo setTempFilePath:[previewManager generateTempPath:item]];
    [previewManager cachePreviewFile:downloadInfo];

    [self showDocument:item withPath:[previewManager generateCachePath:item]];
    
    self.currentPreviewRequest = nil;
    [self.tableView setAllowsSelection:YES];
}

- (void) downloadPreviewFileStarted:(CMISObject*) item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self getIndexPathForItem:item];
        RepositoryNodeViewCell *cell = (RepositoryNodeViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        [cell.progressBar setProgress:0.0f];
        [cell.lblDetails setHidden:YES];
        [cell.progressBar setHidden:NO];
        [cell setIsDownloadingPreview:YES];
    });
}

- (void) updatePreviewDownloadProgress:(NSDictionary*) progressInfo {
    dispatch_async(dispatch_get_main_queue(), ^ {
        if (progressInfo) {
            CMISObject *item = [progressInfo objectForKey:@"Item"];
            RepositoryNodeViewCell *cell = (RepositoryNodeViewCell*)[self.tableView cellForRowAtIndexPath:[self getIndexPathForItem:item]];
            if (cell) {
                NSNumber *downloadBytes = [progressInfo objectForKey:@"DownloadedBytes"];
                NSNumber *totalBytes = [progressInfo objectForKey:@"TotalBytes"];
                [cell.progressBar setProgress:(downloadBytes.longLongValue*1.0)/totalBytes.longLongValue];
            }
        }
    });
}

- (void) showDocument:(CMISObject*) item withPath:(NSString*) filePath{
    UIStoryboard *mainStoryboard = instanceMainStoryboard();
    DocumentViewController *doc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DocumentControllerIdentifier"];
    [doc setCmisObjectId:item.identifier];
    //[doc setContentMimeType:info.repositoryItem];
    [doc setHidesBottomBarWhenPushed:YES];
    [doc setSelectedAccountUUID:self.selectedAccountUUID];
    [doc setTenantID:nil];
    
    DownloadInfo *info = [[DownloadInfo alloc] initWithRepositoryItem:item withAcctUUID:self.selectedAccountUUID withRepositoryID:self.repositoryIdentifier withTenantID:nil];
    DownloadMetadata *fileMetadata = info.downloadMetadata;
    [doc setFileMetadata:fileMetadata];
    [doc setFileName:item.name];
    [doc setFilePath:filePath];
    
    // Special case in the iPhone to avoid chained animations when presenting the edit view
    // only right after creating a file, otherwise we animate the transition
    if (!IS_IPAD)
    {
        [self.navigationController pushViewController:doc animated:NO];
    }
    else
    {
        [IpadSupport pushDetailController:doc withNavigation:self.navigationController andSender:self];
    }
    [self.tableView setAllowsSelection:YES];
}

- (NSIndexPath *)getIndexPathForItem:(CMISObject *)item {
    for (NSInteger i = 0; i < [self.pagedFolders.resultArray count]; i++) {
        CMISObject *fileObj = [self.pagedFolders.resultArray objectAtIndex:i];
        if ([fileObj.identifier isEqualToCaseInsensitiveString:item.identifier]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

@end
