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
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  DocumentViewController.m
//

#import "DocumentViewController.h"
#import "FileUtils.h"
#import "Utility.h"
//#import "FileDownloadManager.h"
#import "TransparentToolbar.h"
#import "MBProgressHUD.h"
#import "BarButtonBadge.h"
#import "AccountManager.h"
#import "MediaPlayer/MPMoviePlayerController.h"
#import "MediaPlayer/MPMoviePlayerViewController.h"
#import "AppDelegate.h"
#import "IpadSupport.h"
#import "ImageActionSheet.h"
#import "MessageViewController.h"
#import "TTTAttributedLabel.h"
//#import "WEPopoverController.h"
#import "ConnectivityManager.h"
//#import "SaveBackMetadata.h"
#import "DownloadInfo.h"
#import "CustomLongPressGestureRecognizer.h"
#import "DetailNavigationController.h"
#import "FileProtectionManager.h"

#define kToolbarSpacerWidth 7.5f
#define kFrameLoadCodeError 102

#define kAlertViewOverwriteConfirmation 1
#define kAlertViewDeleteConfirmation 2

@interface DocumentViewController (private) 
- (void)newDocumentPopover;
- (void)enterEditMode:(BOOL)animated;
- (void)loadCommentsViewController:(NSDictionary *)model;
- (void)replaceCommentButtonWithBadge:(NSString *)badgeTitle;
- (void)startHUD;
- (void)stopHUD;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)fixMimeTypeFor:(NSString *)originalMimeType;
- (void)reachabilityChanged:(NSNotification *)notification;
@end

@implementation DocumentViewController

BOOL isFullScreen = NO;

NSInteger const kGetCommentsCountTag = 6;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _cmisObjectId = nil;
	_fileData = nil;
	_fileName = nil;
    _filePath = nil;
    _contentMimeType = nil;
    _fileMetadata = nil;
	_documentToolbar = nil;
	_favoriteButton = nil;
	_webView = nil;
    _likeBarButton = nil;
	_docInteractionController = nil;
    _actionButton = nil;
    _actionSheet = nil;
    _actionSheetSenderControl = nil;
    _commentButton = nil;
    _editButton = nil;
    _previewRequest = nil;
    _HUD = nil;
    _popover = nil;
    _selectedAccountUUID = nil;
    _tenantID = nil;
    _repositoryID = nil;
    
    _backButtonTitle = nil;
    _playMediaButton = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.showTrashButton = YES;
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.popover dismissPopoverAnimated:YES];
    if (self.actionSheet.isVisible)
    {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:NO];
    }
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.presentNewDocumentPopover)
    {
        [self setPresentNewDocumentPopover:NO];
        [self newDocumentPopover];
    }
    else if (self.presentEditMode)
    {
        [self setPresentEditMode:NO];
        if (IS_IPAD)
        {
            //At this point the appear animation is happening delaying half a second
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                [self enterEditMode:YES];
            });
        }
        else
        {
            [self enterEditMode:NO];
        }
    }
    else
    {
        long fileSize = self.fileMetadata.metadata.fileSize;
        if (fileSize == 0)
        {
            // See what the temp/local file size is in case the document doesn't have fileMetadata set correctly
            NSFileManager *fileManager = [NSFileManager new];
            NSError *error = nil;
            fileSize = [[[fileManager attributesOfItemAtPath:self.filePath error:&error] objectForKey:NSFileSize] longValue];
            if (error != nil)
            {
                fileSize = 0;
            }
        }
        
        if (fileSize == 0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                displayWarningMessageWithTitle(NSLocalizedString(@"noContentWarningMessage", @"This document has no content."), NSLocalizedString(@"noContentWarningTitle", @"No content"));
            });
        }
        else if (self.presentMediaViewController)
        {
            self.presentMediaViewController = NO;
            [self startMediaPlaying];
        }
    }
    [self updateRemoteRequestActionAvailability];
}


/*
 Started with the idea in http://stackoverflow.com/questions/1110052/uiview-doesnt-resize-to-full-screen-when-hiding-the-nav-bar-tab-bar
 UIView doesn't resize to full screen when hiding the nav bar & tab bar
 
 made several changes, including changing tab bar for custom toolbar
 */
- (void)handleTap:(UIGestureRecognizer *)sender
{
    isFullScreen = !isFullScreen;
    
    [UIView beginAnimations:@"fullscreen" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.3];
    
    // Move tab bar up/down
    // We don't need the logic to hide the toolbar in the ipad since the toolbar is in the nav bar
    if (!IS_IPAD)
    {
        CGRect tabBarFrame = self.documentToolbar.frame;
        CGFloat tabBarHeight = tabBarFrame.size.height;
        CGFloat offset = isFullScreen ? tabBarHeight : -1 * tabBarHeight;
        CGFloat tabBarY = tabBarFrame.origin.y + offset;
        tabBarFrame.origin.y = tabBarY;
        self.documentToolbar.frame = tabBarFrame;
        
        
        CGRect webViewFrame = self.webView.frame;
        CGFloat webViewHeight = webViewFrame.size.height+ offset;
        if (IOS7_OR_LATER) {
            if (isFullScreen) {  //to fix the status bar for ios7
                webViewHeight += 20;
            }else {
                webViewHeight -= 20;
            }
        }
        webViewFrame.size.height = webViewHeight;
        self.webView.frame = webViewFrame;
        // Fade it in/out
        self.navigationController.navigationBar.alpha = isFullScreen ? 0 : 1;
        self.documentToolbar.alpha = isFullScreen ? 0 : 1;
        
        // Resize webview to be full screen / normal
        [self.webView removeFromSuperview];
        [self.view addSubview:self.webView];
    }
    
    [self.navigationController setNavigationBarHidden:isFullScreen animated:YES];
    
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/**
 * CustomLongPressGesture Recognizer Action
 */
- (void)longPressDetected:(UIGestureRecognizer *)sender
{
    // Toggling the userInteractionEnabled flag will remove the UIMenuController from view
    [self.webView setUserInteractionEnabled:NO];
    [self.webView setUserInteractionEnabled:YES];
}

- (void)handleSyncObstaclesNotification:(NSNotification *)notification
{
    // Only relevant if device is not iPad
    if (!IS_IPAD)
    {
        NSString *docID = [self.cmisObjectId lastPathComponent];
        NSArray *viewControllers = [self.navigationController viewControllers];

        if ([viewControllers count] > 1 )
        {
            BOOL existsInObstacles = NO;
            NSDictionary *syncObstacles = notification.userInfo[@"syncObstacles"];
            //NSArray *syncDocUnfavorited = [syncObstacles objectForKey:kDocumentsUnfavoritedOnServerWithLocalChanges];
            //NSArray *syncDocDeleted = [syncObstacles objectForKey:kDocumentsDeletedOnServerWithLocalChanges];
            
//            if (syncDocUnfavorited.count > 0)
//            {
//                for (NSString *docName in syncDocUnfavorited)
//                {
//                    if ([docID isEqualToString:[docName stringByDeletingPathExtension]])
//                    {
//                        existsInObstacles = YES;
//                        break;
//                    }
//                }
//            }
//
//            if (!existsInObstacles && syncDocDeleted.count > 0)
//            {
//                for (NSString *docName in syncDocDeleted)
//                {
//                    if ([docID isEqualToString:[docName stringByDeletingPathExtension]])
//                    {
//                        existsInObstacles = YES;
//                        break;
//                    }
//                }
//            }
            
            if (existsInObstacles)
            {
                [self.navigationController popViewControllerAnimated:NO];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger spacersCount = 0;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncObstaclesNotification:) name:kNotificationSyncObstacles object:nil];
    
    self.webView.isRestrictedDocument = self.isRestrictedDocument;
    
    AccountInfo *account = [[AccountManager sharedManager] accountInfoForUUID:self.selectedAccountUUID];
    
    NSMutableArray *updatedItemsArray = [NSMutableArray arrayWithArray:[self.documentToolbar items]];
    NSString *title = self.fileMetadata ? self.fileMetadata.filename : self.fileName;
    
    // Double-tap toggles the navigation bar
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tapRecognizer setDelegate:self];
    [tapRecognizer setNumberOfTapsRequired:2];
    [self.webView addGestureRecognizer:tapRecognizer];
    
    // Optionally override long-press to suppress UIMenuController
    if (self.isRestrictedDocument && [self.fileName.pathExtension isEqualToCaseInsensitiveString:@"pdf"])
    {
        CustomLongPressGestureRecognizer *longPressRecognizer = [[CustomLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
        [self.webView addGestureRecognizer:longPressRecognizer];
    }
    
    // For the ipad toolbar we don't have the flexible space as the first element of the toolbar items
	NSInteger actionButtonIndex = IS_IPAD ? 0 : 1;
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(performAction:)];
    self.actionSheetSenderControl = self.actionButton;
    [self buildActionMenu];
    //[updatedItemsArray insertObject:[self iconSpacer] atIndex:actionButtonIndex];
    //spacersCount++;
    [updatedItemsArray insertObject:self.actionButton atIndex:actionButtonIndex];
    
    [[self documentToolbar] setItems:updatedItemsArray];
    
    [self.webView setAlpha:0.0];
    [self.webView setScalesPageToFit:YES];
    [self.webView setMediaPlaybackRequiresUserAction:NO];
    [self.webView setAllowsInlineMediaPlayback:NO];
    
	// write the file contents to the file system
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.fileName];
    
    if (self.fileData)
    {
        [self.fileData writeToFile:path atomically:NO];
    }
    else if (self.filePath)
    {
        // If filepath is set, it is preferred from the filename in the temp path
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tempPath = [FileUtils pathToTempFile:[self.filePath lastPathComponent]];
        //We only use it if the file is in the temp path
        if ([fileManager fileExistsAtPath:tempPath])
        {
            path = self.filePath;
        }
        else
        {
            // Can happen when ASIHTTPRequest returns a cached file
            NSError *error = nil;
            // Ignore the error
            [fileManager removeItemAtPath:path error:nil];
            [fileManager copyItemAtPath:self.filePath toPath:path error:&error];
            
            if (error)
            {
                ODSLogDebug(@"Error copying file to temp path %@", [error description]);
            }
        }
    }
	
	// Get a URL that points to the file on the filesystem
	NSURL *url = [NSURL fileURLWithPath:path];
    
    if (!self.contentMimeType || [self.contentMimeType isEqualToCaseInsensitiveString:@"application/octet-stream"])
    {
        self.contentMimeType = mimeTypeForFilename([url lastPathComponent]);
    }
    
    self.contentMimeType = [self fixMimeTypeFor:self.contentMimeType];
    self.previewRequest = [NSURLRequest requestWithURL:url];
    BOOL isVideo = isVideoExtension(url.pathExtension);
    BOOL isAudio = isAudioExtension(url.pathExtension);
    BOOL isIWork = isIWorkExtension(url.pathExtension);
    
    if (self.contentMimeType)
    {
        if (self.fileData)
        {
            [self.webView loadData:self.fileData MIMEType:self.contentMimeType textEncodingName:@"UTF-8" baseURL:url];
        }
        else if (isVideo || isAudio)
        {
            [self.webView removeFromSuperview];
            self.webView = nil;
            
            self.presentMediaViewController = YES;
        }
        else if (isIWork)
        {
            [self.webView loadRequest:self.previewRequest];
        }
        else
        {
            [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:path];
            NSData *requestData = [NSData dataWithContentsOfFile:path];
            [self.webView loadData:requestData MIMEType:self.contentMimeType textEncodingName:@"UTF-8" baseURL:url];
        }
    }
    else
    {
        [self.webView loadRequest:self.previewRequest];
    }
    
    [self.webView setDelegate:self];
	
	//We move the tool to the nav bar in the ipad
    if (IS_IPAD) 
    {
        [self.documentToolbar removeFromSuperview];
        self.navigationItem.rightBarButtonItems = self.documentToolbar.items;//[[[UIBarButtonItem alloc] initWithCustomView:ipadToolbar] autorelease];
        //[ipadToolbar release];
        
        // Adding the height of the toolbar
        if (self.webView)
        {
            self.webView.frame = self.view.frame;
        }
    }
    
	// we want to release this object since it may take a lot of memory space
    self.fileData = nil;
	
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setTitle:title];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentUpdated:) name:kNotificationDocumentUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStatusChanged:) name:kNotificationAccountStatusChanged object:nil];
}

//- (WEPopoverContainerViewProperties *)improvedContainerViewProperties
//{
//	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] autorelease];
//	NSString *bgImageName = nil;
//	CGFloat bgMargin = 0.0;
//	CGFloat bgCapSize = 0.0;
//	CGFloat contentMargin = 4.0;
//	
//	bgImageName = @"white-bg-popover.png";
//	
//	// These constants are determined by the popoverBg.png image file and are image dependent
//	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13 
//	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
//	
//	props.leftBgMargin = bgMargin;
//	props.rightBgMargin = bgMargin;
//	props.topBgMargin = bgMargin;
//	props.bottomBgMargin = bgMargin + 1; //The bottom margin seems to be off by 1 pixel, this is hardcoded and depends on the white-bg-popover.png/white-bg-popover-arrow.png
//	props.leftBgCapSize = bgCapSize;
//	props.topBgCapSize = bgCapSize;
//	props.bgImageName = bgImageName;
//	props.leftContentMargin = contentMargin;
//	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
//	props.topContentMargin = contentMargin; 
//	props.bottomContentMargin = contentMargin;
//	
//	props.arrowMargin = 4.0;
//	
//	props.upArrowImageName = @"white-bg-popover-arrow.png";
//	return props;	
//}


- (NSString *)fixMimeTypeFor:(NSString *)originalMimeType 
{
    NSDictionary *mimeTypesFix = [NSDictionary dictionaryWithObject:@"audio/mp4" forKey:@"audio/m4a"];
    
    NSString *fixedMimeType = [mimeTypesFix objectForKey:originalMimeType];
    return fixedMimeType?fixedMimeType:originalMimeType;
}

- (UIBarButtonItem *)iconSpacer
{       
    UIBarButtonItem *iconSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                 target:nil action:nil];
    [iconSpacer setWidth:kToolbarSpacerWidth];
    return iconSpacer;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)updateRemoteRequestActionAvailability
{
    BOOL canPerformRemoteRequests = self.canPerformRemoteRequests;
    if (!self.actionSheet.isVisible)
    {
        //[self enableDocumentActionToolbarControls:canPerformRemoteRequests allowOfflineActions:YES animated:NO];
        [self buildActionMenu];
    }
}

- (BOOL)canPerformRemoteRequests
{
    BOOL hasInternetConnection = [[ConnectivityManager sharedManager] hasInternetConnection];
    BOOL accountIsActive = (self.selectedAccountUUID && [[AccountManager sharedManager] isAccountActive:self.selectedAccountUUID]);
    return hasInternetConnection && accountIsActive;
}

#pragma mark - Action Selectors

- (void)emailDocumentAsAttachment
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setSubject:self.fileName];
        [mailer setMessageBody:NSLocalizedString(@"email.footer.text", @"Sent from ...") isHTML:NO];

        NSString *mimeType = nil;
        if (self.contentMimeType)
        {
            mimeType = self.contentMimeType;
        }
        else
        {
            mimeType = mimeTypeForFilenameWithDefault(self.fileName, @"application/octet-stream");
        }
        
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.fileName];
        
        if (self.filePath)
        {
            // If filepath is set, it is preferred from the filename in the temp path
            path = self.filePath;
        }
        [mailer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:mimeType fileName:self.fileName];

        [self presentModalViewController:mailer animated:YES];
        mailer.mailComposeDelegate = self;
    }
    else
    {
        displayErrorMessageWithTitle(NSLocalizedString(@"noEmailSetupDialogMessage", @"Mail is currently not setup on your device and is required to send emails"), NSLocalizedString(@"noEmailSetupDialogTitle", @"Mail Setup"));
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)buildActionMenu
{
    BOOL isVideo = isVideoExtension([self.fileName pathExtension]);
    BOOL isAudio = isAudioExtension([self.fileName pathExtension]);
    
    if (self.actionSheet && self.actionSheet.isVisible)
    {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:NO];
    }
    
    self.actionSheet = [[ImageActionSheet alloc] initWithTitle:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                     otherButtonTitlesAndImages: nil];
    
    if (!self.isRestrictedDocument)
    {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"documentview.action.openin", @"Open in...") andImage:[UIImage imageNamed:@"open-in.png"]];
    
        if ([MFMailComposeViewController canSendMail])
        {
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"documentview.action.email.attachment", @"Email attachment") andImage:[UIImage imageNamed:@"send-email.png"]];
        }
    }
    
    if (!self.isDownloaded)
    {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"documentview.action.download", @"Download action text") andImage:[UIImage imageNamed:@"download-action.png"]];
    }
    else if (self.showTrashButton)
    {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"documentview.action.delete", @"Delete action text") andImage:[UIImage imageNamed:@"delete-action.png"]];
    }
    
    // Not allowed to print audio or video files
    if (!self.isRestrictedDocument && !isAudio && !isVideo)
    {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"documentview.action.print", @"Print") andImage:[UIImage imageNamed:@"print-action.png"]];
    }
    
    [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:NSLocalizedString(@"add.actionsheet.cancel", @"Cancel")]];
}

- (void)performAction:(id)sender
{
    [self.popover dismissPopoverAnimated:YES];
    
    if (IS_IPAD)
    {
        [self enableAllToolbarControls:NO animated:YES];
        [self.actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
        [self.actionSheet showFromBarButtonItem:sender animated:YES];
    }
    else
    {
        [self.actionSheet showFromBarButtonItem:sender animated:YES];
    }
}

- (IBAction)playButtonTapped:(id)sender
{
    [self startMediaPlaying];
}

- (void)startMediaPlaying
{
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    
    // At this point the appear animation is happening, so delay half a second
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self.playMediaButton setHidden:NO];
    });
}

- (void)editDocumentAction:(id)sender
{
    [self enterEditMode:YES];
}

/**
 * Enables/disables all toolbar controls, including the actionSheet button
 */
- (void)enableAllToolbarControls:(BOOL)enable animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:@"toolbarButtons" context:NULL];
        [UIView setAnimationDuration:0.3];
    }
    [self.actionSheetSenderControl setEnabled:enable];
    if (animated)
    {
        [UIView commitAnimations];
    }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSString *buttonLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonLabel isEqualToString:NSLocalizedString(@"documentview.action.openin", @"Open in...")]) 
        {
            [self actionButtonPressed:self.actionButton];
        } 
        else if ([buttonLabel isEqualToString:NSLocalizedString(@"documentview.action.print", @"Print")]) 
        {
            UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = self.navigationController.title;
            
            printController.printInfo = printInfo;
            printController.printFormatter = [self.webView viewPrintFormatter];
            printController.showsPageRange = YES;
            
            UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *controller, BOOL completed, NSError *error)
            {
                [self enableAllToolbarControls:YES animated:YES];
                if (!completed && error)
                {
                    ODSLogDebug(@"Printing could not complete because of error: %@", error);
                }
            };
            
            if (IS_IPAD)
            {
                [printController presentFromBarButtonItem:self.actionButton animated:YES completionHandler:completionHandler];
            }
            else
            {
                [printController presentAnimated:YES completionHandler:completionHandler];
            }
        }
        else
        {
            if ([buttonLabel isEqualToString:NSLocalizedString(@"documentview.action.email.attachment", @"Email action text")])
            {
                [self emailDocumentAsAttachment];
            }
            else if ([buttonLabel isEqualToString:NSLocalizedString(@"documentview.action.download", @"Download action text")])
            {
                [self downloadButtonPressed];
            }
            else if ([buttonLabel isEqualToString:NSLocalizedString(@"documentview.action.delete", @"Delete action text")])
            {
                [self trashButtonPressed];
            }
            [self enableAllToolbarControls:YES animated:YES];
        }
    });
}

- (IBAction)actionButtonPressed:(UIBarButtonItem *)sender
{
    // Copy the file to temp with the correct name
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.fileName];
    [FileUtils saveFileFrom:self.filePath toDestination:path overwriteExisting:YES];
    
    [self setDocInteractionController:[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]]];
    [self.docInteractionController setDelegate:self];
		
    if (![self.docInteractionController presentOpenInMenuFromBarButtonItem:sender animated:YES])
    {
        displayErrorMessageWithTitle(NSLocalizedString(@"noAppsAvailableDialogMessage", @"There are no applications that are capable of opening this file on this device"), NSLocalizedString(@"noAppsAvailableDialogTitle", @"No Applications Available"));
    }
}


- (void)downloadButtonPressed
{
//    if ([[FileDownloadManager sharedInstance] downloadExistsForKey:self.fileName])
//    {
//        UIAlertView *overwritePrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"documentview.overwrite.download.prompt.title", @"")
//                                                                   message:NSLocalizedString(@"documentview.overwrite.download.prompt.message", @"Yes/No Question")
//                                                                  delegate:self 
//                                                         cancelButtonTitle:NSLocalizedString(@"No", @"No") 
//                                                         otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
//        
//        [overwritePrompt setTag:kAlertViewOverwriteConfirmation];
//        [overwritePrompt show];
//    }
//    else
//    {
//        [self saveFileLocally];
//    }
}

- (void)saveFileLocally 
{
    // FileDownloadManager only handles files in the temp folder, so we need to save the file there first
    NSString *tempPath = [FileUtils pathToTempFile:self.fileName];
    if (![tempPath isEqualToString:self.filePath])
    {
        [FileUtils saveFileFrom:self.filePath toDestination:tempPath overwriteExisting:YES];
    }
//    
//    FileDownloadManager *manager = [FileDownloadManager sharedInstance];
//    [manager setOverwriteExistingDownloads:YES];
//    NSString *filename = [[FileDownloadManager sharedInstance] setDownload:self.fileMetadata.downloadInfo forKey:self.fileName withFilePath:self.fileName];
//
//    // Since the file was moved from the temp path to the save file we want to update the file path to the one in the saved documents
//    self.filePath = [FileUtils pathToSavedFile:filename];
    
    displayInformationMessage(NSLocalizedString(@"documentview.download.confirmation.title", @"Document Saved"));
}

- (void)trashButtonPressed
{
    UIAlertView *deleteConfirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"documentview.delete.confirmation.title", @"")
                                                                       message:NSLocalizedString(@"documentview.delete.confirmation.message", @"Do you want to remove this document from your device?") 
                                                                      delegate:self 
                                                             cancelButtonTitle:NSLocalizedString(@"No", @"No") 
                                                             otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];

    [deleteConfirmationAlert setTag:kAlertViewDeleteConfirmation];
    [deleteConfirmationAlert show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kAlertViewOverwriteConfirmation:
        {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                [self saveFileLocally];
            }
            break;
        }
        case kAlertViewDeleteConfirmation:
        {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                ODSLogDebug(@"User confirmed removal of file %@", self.fileName);
                //[[FileDownloadManager sharedInstance] removeDownloadInfoForFilename:self.fileName];
            }
            break;
        }
        default:
        {
            ODSLogDebug(@"Unknown AlertView!");
            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewDeleteConfirmation && buttonIndex != alertView.cancelButtonIndex)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
        if (IS_IPAD)
        {
            [IpadSupport clearDetailController];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    self.docInteractionController = nil;
    return self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    [self enableAllToolbarControls:YES animated:YES];

//    SaveBackMetadata *saveBackMetadata = [[[SaveBackMetadata alloc] init] autorelease];
//    saveBackMetadata.originalPath = self.filePath;
//    saveBackMetadata.originalName = self.fileName;
//    if (!self.isDownloaded)
//    {
//        saveBackMetadata.accountUUID = self.selectedAccountUUID;
//        saveBackMetadata.tenantID = self.tenantID;
//        saveBackMetadata.objectId = self.cmisObjectId;
//    }
//    
//    NSString *appIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"AppIdentifier"];
//    NSDictionary *annotation = nil;
//
//    if ([application hasPrefix:QuickofficeBundleIdentifier])
//    {
//        // Quickoffice SaveBack API parameters
//        annotation = [NSDictionary dictionaryWithObjectsAndKeys:
//                        externalAPIKey(APIKeyQuickoffice), QuickofficeApplicationSecretUUIDKey,
//                        saveBackMetadata.dictionaryRepresentation, QuickofficeApplicationInfoKey,
//                        appIdentifier, QuickofficeApplicationIdentifierKey,
//                        QuickofficeApplicationDocumentExtension, QuickofficeApplicationDocumentExtensionKey,
//                        QuickofficeApplicationDocumentUTI, QuickofficeApplicationDocumentUTIKey,
//                        nil];
//    }
//    else
//    {
//        // Alfresco SaveBack API parameters
//        annotation = [NSDictionary dictionaryWithObjectsAndKeys:
//                        saveBackMetadata.dictionaryRepresentation, AlfrescoSaveBackMetadataKey,
//                        nil];
//    }
    
//    self.docInteractionController.annotation = annotation;
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    self.docInteractionController = nil;
    [self enableAllToolbarControls:YES animated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kDocumentFadeInTime];
    [self.webView setAlpha:1.0];
    [UIView commitAnimations];
}

/**
 * We want to know when the document cannot be rendered
 * UIWebView throws two errors when a document cannot be previewed
 * code:100 message: "Operation could not be completed. (NSURLErrorDomain error 100.)"
 * code:102 message: "Frame load interrupted"
 *
 * Note we also get an error when loading a video, as rendering is handed off to a QuickTime plug-in
 * code:204 message: "Plug-in handled load"
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    ODSLogDebug(@"Failed to load preview: %@", [error description]);
    if ([error code] == kFrameLoadCodeError)
    {
        [self performSelectorOnMainThread:@selector(previewLoadFailed) withObject:nil waitUntilDone:NO];
    }
    [self.webView setAlpha:1.0];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther && [request.URL.scheme hasPrefix:@"http"])
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;    
}

- (void)previewLoadFailed
{
    displayErrorMessage(NSLocalizedString(@"documentview.preview.failure.message", @"Failed to preview the document"));
    [self.webView setAlpha:1.0];
}

#pragma mark - MBProgressHUD Helper Methods

- (void)startHUD
{
	if (!self.HUD)
    {
		self.HUD = createAndShowProgressHUDForView(self.webView);
	}
}

- (void)stopHUD
{
	if (self.HUD)
    {
        stopProgressHUD(self.HUD);
		self.HUD = nil;
	}
}

#pragma mark - NotificationCenter methods
- (void)documentUpdated:(NSNotification *)notification
{
    NSString *objectId = [notification.userInfo objectForKey:@"objectId"];
    NSString *newPath = [notification.userInfo objectForKey:@"newPath"];
    
//    if ([objectId isEqualToString:self.cmisObjectId] && newPath != nil)
//    {
//        [self setFilePath:newPath];
//        self.previewRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:newPath]];
//        [self.webView loadRequest:self.previewRequest];
//
//        RepositoryItem *repositoryItem = [notification.userInfo objectForKey:@"repositoryItem"];
//        if (repositoryItem != nil)
//        {
//            DownloadInfo *downloadInfo = [[[DownloadInfo alloc] initWithRepositoryItem:repositoryItem] autorelease];
//            self.fileMetadata = downloadInfo.downloadMetadata;
//        }
//    }
}

/**
 * Listening to the reachability changes to determine if we should enable/disable
 * buttons that require an internet connection to work
 */
- (void)reachabilityChanged:(NSNotification *)notification
{
    [self updateRemoteRequestActionAvailability];
}

/**
 * Account Status changed Notification Method
 */
- (void)accountStatusChanged:(NSNotification *)notification
{
    NSString *accountID = [notification.userInfo objectForKey:@"uuid"];
    if ([accountID isEqualToString:self.selectedAccountUUID])
    {
        [self updateRemoteRequestActionAvailability];
    }
}

/**
 * Restricted Files expired Notification
 */
- (void)handleFilesExpired:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *docID = [self.cmisObjectId lastPathComponent];
    NSArray *expiredSyncFiles = userInfo[@"expiredSyncFiles"];
    NSArray *expiredDownloadFiles = userInfo[@"expiredDownloadFiles"];
    
    // Check sync'ed files collection
    for (NSString *doc in expiredSyncFiles)
    {
        if ([docID isEqualToString:[doc stringByDeletingPathExtension]])
        {
            self.isDocumentExpired = YES;
            break;
        }
    }
    if (!self.isDocumentExpired)
    {
        // Check downloaded files collection
        for (NSString *doc in expiredDownloadFiles)
        {
            if ([doc isEqualToString:self.title])
            {
                self.isDocumentExpired = YES;
                break;
            }
        }
    }
    
    if (!self.isEditingDocument && self.isDocumentExpired)
    {
        if (IS_IPAD)
        {
            [IpadSupport clearDetailController];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

/**
 * Update Restriction Status Notification
 */
- (void)updateDocumentRestrictionStatus:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    BOOL currentStatus = [userInfo[@"restrictionStatus"] boolValue];
    
    [self setIsRestrictedDocument:currentStatus];
    [self.webView setIsRestrictedDocument:currentStatus];
    
    [self buildActionMenu];
}

#pragma mark - File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)viewDidUnload {
    [self setPlayMediaButton:nil];
    [super viewDidUnload];
}
@end
