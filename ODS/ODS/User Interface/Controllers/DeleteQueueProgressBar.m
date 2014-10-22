/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  DeleteQueueProgressBar.m
//

#import "DeleteQueueProgressBar.h"
#import "AccountManager.h"

#import "CMISFolder.h"
#import "CMISDocument.h"
#import "CMISRequest.h"

NSInteger const kDeleteCounterTag =  6;

@interface DeleteQueueProgressBar ()

@property (nonatomic, assign) BOOL  isCancel;
@property (nonatomic, strong) CMISRequest *currentRequest;
- (void) loadDeleteView;
- (void) updateProgressView;
@end

@implementation DeleteQueueProgressBar
@synthesize itemsToDelete = _itemsToDelete;
@synthesize delegate = _delegate;
@synthesize progressAlert = _progressAlert;
@synthesize progressTitle = _progressTitle;
@synthesize progressView = _progressView;
@synthesize selectedUUID = _selectedUUID;
@synthesize tenantID = _tenantID;
@synthesize deletedItems = _deletedItems;

- (void) dealloc
{
    _itemsToDelete = nil;
    _progressAlert = nil;
    _progressTitle = nil;
    _progressView = nil;
    _deletedItems = nil;
    _selectedUUID = nil;
    _tenantID = nil;
}

- (id)initWithItems:(NSArray *)itemsToDelete delegate:(id<DeleteQueueDelegate>)del andMessage:(NSString *)message
{
    self = [super init];
    if (self)
    {
        self.itemsToDelete = [NSMutableArray arrayWithArray:itemsToDelete];
        self.delegate = del;
        self.progressTitle = message;
        _deletedItems = [NSMutableArray array];
        self.isCancel = NO;
        self.currentRequest = nil;
        [self loadDeleteView];
    }
    
    return self;
}

#pragma mark - private methods
- (void)loadDeleteView
{
    // create a modal alert
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.progressTitle
                                                    message:NSLocalizedString(@"pleaseWaitMessage", @"Please Wait...") 
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancelButton", @"Cancel")
                                          otherButtonTitles:nil];
    alert.message = [NSString stringWithFormat: @"%@%@", alert.message, @"\n\n\n\n"];
    self.progressAlert = alert;
	
	// create a progress bar and put it in the alert
	UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
    self.progressView = progress;
    [progress setProgressViewStyle:UIProgressViewStyleBar];
	[self.progressAlert addSubview:self.progressView];
	
	// create a label, and add that to the alert, too
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 90.0f, 225.0f, 40.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13.0f];
    label.text = @"x files left";
    label.tag = kDeleteCounterTag;
    [self.progressAlert addSubview:label];
}

- (void) updateProgressView
{
    UILabel *label = (UILabel *)[self.progressAlert viewWithTag:kDeleteCounterTag];
    if([self.itemsToDelete count] == 1)
    {
        label.text = [NSString stringWithFormat:NSLocalizedString(@"deleteprogress.file-left", @"1 item left"), 
                      [self.itemsToDelete count]];
    }
    else 
    {
        label.text = [NSString stringWithFormat:NSLocalizedString(@"deleteprogress.files-left", @"x items left"), 
                      [self.itemsToDelete count]];
    }
}

#pragma mark - public methods
- (void) startDeleting
{
    [self startDeleteItem];
    [self.progressAlert show];
    [self updateProgressView];
}

- (void) startDeleteItem {
    if ([self isCancel]) {
        return ;
    }
    
    if ([self.itemsToDelete count] > 0) {
        CMISObject *obj = [self.itemsToDelete objectAtIndex:0];
        if (isCMISFolder(obj)) {
            CMISFolder *folder = (CMISFolder *) obj;
            self.currentRequest = [folder deleteTreeWithDeleteAllVersions:YES unfileObjects:CMISDelete continueOnFailure:NO completionBlock:^(NSArray *failedObjects, NSError *error) {
                if (error != nil) {
                    ODSLogError(@"delete folder item error:%@", error);
                }else {
                    [self saveDeletedItems];
                }
                
                [self removeDeletedItemFromList];
                [self updateProgressView];
                [self startDeleteItem];
            }];
        }else {
            CMISDocument *doc = (CMISDocument*)obj;
            self.currentRequest = [doc deleteAllVersionsWithCompletionBlock:^(BOOL docmentDeleted, NSError *error) {
                if (docmentDeleted) {
                    [self saveDeletedItems];
                }else {
                    ODSLogError(@"delete item error:%@", error);
                }
                [self removeDeletedItemFromList];
                [self updateProgressView];
                [self startDeleteItem];
            }];
        }
    }else {  //All items were deleted.
        [_progressAlert dismissWithClickedButtonIndex:1 animated:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteQueue:completedDeletes:)])  {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate deleteQueue:self completedDeletes:_deletedItems];
            });
        }
    }
}

- (void) saveDeletedItems {
    if ([self.itemsToDelete count] > 0) {
        [_deletedItems addObject:[self.itemsToDelete objectAtIndex:0]];
    }
}

- (void) removeDeletedItemFromList {
    if ([self.itemsToDelete count] > 0) {
        [self.itemsToDelete removeObjectAtIndex:0];
    }
}

- (void) cancel
{
    [_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (NSArray *) deletedItems
{
    return [NSArray arrayWithArray:_deletedItems];
}

- (void) cancelDeleteOperation {
    [self setIsCancel:YES];
    if (self.currentRequest) {
        [self.currentRequest cancel];
        self.currentRequest = nil;
    }
}

#pragma mark - static methods
+ (DeleteQueueProgressBar *) createWithItems:(NSArray *)itemsToDelete delegate:(id<DeleteQueueDelegate>)del andMessage:(NSString *)message
{
    DeleteQueueProgressBar *bar = [[DeleteQueueProgressBar alloc] initWithItems:itemsToDelete delegate:del andMessage:message];
    return bar;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // we only cancel the connection when buttonIndex=0 (cancel)
    if (buttonIndex == 0)
    {
        [self cancelDeleteOperation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteQueueWasCancelled:)])
        {
            [self.delegate deleteQueueWasCancelled:self];
        }
    }
}

@end
