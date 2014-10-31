//
//  ODSConstants.h
//  ODS
//
//  Created by bdt on 9/18/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODSConstants+Notification.h"
#import "ODSConstants+Settings.h"

/* Storyboard Name */
extern NSString * const kMainStoryboardNameiPhone;
extern NSString * const kMainStoryboardNameiPad;

/* API Key for Flurry */
extern NSString * const kFlurryAPIKey;

/**
 * The number of seconds to wait before showing a network activity progress dialog.
 * Currently used by the DownloadProgressBar and PostProgressBar controls.
 */
extern NSTimeInterval const kNetworkProgressDialogGraceTime;

/**
 * The number of seconds that the fade-in animation lasts when displaying documents.
 */
extern NSTimeInterval const kDocumentFadeInTime;

/**
 * The number of seconds that the HUD will de displayed for.
 */
extern NSTimeInterval const kHUDMinShowTime;

/**
 * The number of seconds that the invoked method may be run without
 * showing the HUD.
 */
extern NSTimeInterval const KHUDGraceTime;

//
// General Purpose Constants
//
extern NSString * const kFDHTTP_Protocol;
extern NSString * const kFDHTTPS_Protocol;
extern NSString * const kFDHTTP_DefaultPort;
extern NSString * const kFDHTTPS_DefaultPort;

/**
 * Sync Favorites Preference
 */
extern NSString * const kSyncedFilesDirectory;

extern NSString * const kFDLibraryConfigFolderName;

extern NSString * const kDefaultAccountsPlist_FileName;

/**
 * The number of file suffixes that are tried to avoid file overwrites
 */
extern unsigned int const kFileSuffixMaxAttempts;

/**
 * The name of the images used in the UITableViewCells
 */
extern NSString * const kServerIcon_ImageName;
extern NSString * const kImageUIButtonBarBadgeError;

/**
 * The default UITableViewCell height
 */
extern CGFloat const kDefaultTableCellHeight;

/**
 * System Preference Keys
 */
extern NSString * const kPreferenceApplicationFirstRun;

@interface ODSConstants : NSObject

@end
