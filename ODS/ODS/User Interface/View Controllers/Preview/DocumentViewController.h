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
//  DocumentViewController.h
//

#import <UIKit/UIKit.h>

#import "MessageUI/MFMailComposeViewController.h"
#import "ToggleBarButtonItemDecorator.h"
#import "DownloadMetadata.h"
#import "CustomWebView.h"

@class BarButtonBadge;
@class ImageActionSheet;
@class MBProgressHUD;

@interface DocumentViewController : UIViewController <
    MFMailComposeViewControllerDelegate,
    UIActionSheetDelegate,
    UIAlertViewDelegate,
    UIDocumentInteractionControllerDelegate,
    UIGestureRecognizerDelegate,
    UIWebViewDelegate>

@property (nonatomic, copy) NSString *cmisObjectId;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *contentMimeType;
@property (nonatomic, strong) DownloadMetadata *fileMetadata;
@property (nonatomic, strong) NSURLRequest *previewRequest;
@property (nonatomic, assign) BOOL isDownloaded;
@property (nonatomic, weak) IBOutlet UIToolbar *documentToolbar;
@property (nonatomic, strong) ToggleBarButtonItemDecorator *favoriteButton;
@property (nonatomic, strong) ToggleBarButtonItemDecorator *likeBarButton;
@property (nonatomic, weak) IBOutlet CustomWebView *webView;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) ImageActionSheet *actionSheet;
@property (nonatomic, strong) UIBarButtonItem *actionSheetSenderControl;
@property (nonatomic, strong) UIBarButtonItem *commentButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, copy) NSString *backButtonTitle;
@property (nonatomic, assign) BOOL showLikeButton;
@property (nonatomic, assign) BOOL showTrashButton;
@property (nonatomic, assign) BOOL showReviewButton;
@property (nonatomic, assign) BOOL showFavoriteButton;
@property (nonatomic, assign) BOOL isVersionDocument;
@property (nonatomic, assign) BOOL presentNewDocumentPopover;
@property (nonatomic, assign) BOOL presentEditMode;
@property (nonatomic, assign) BOOL presentMediaViewController;
@property (nonatomic, assign) BOOL canEditDocument;
@property (nonatomic, assign) BOOL hasNodeLocation;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, copy) NSString *selectedAccountUUID;
@property (nonatomic, copy) NSString *tenantID;
@property (nonatomic, copy) NSString *repositoryID;
@property (nonatomic, weak) IBOutlet UIButton *playMediaButton;
@property (nonatomic, assign) BOOL isRestrictedDocument;
@property (nonatomic, assign) BOOL isDocumentExpired;
@property (nonatomic, assign) BOOL isEditingDocument;

- (UIBarButtonItem *)iconSpacer;
- (void)emailDocumentAsAttachment;
- (IBAction)actionButtonPressed:(id)sender;
- (void)downloadButtonPressed;
- (void)saveFileLocally;
- (void)trashButtonPressed;
- (void)performAction:(id)sender;
- (IBAction)playButtonTapped:(id)sender;

@end
