//
//  ODSConstants.m
//  ODS
//
//  Created by bdt on 9/18/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ODSConstants.h"

/* Storyboard Name */
NSString * const kMainStoryboardNameiPhone = @"Main_iPhone";
NSString * const kMainStoryboardNameiPad = @"Main_iPad";

/* API Key for Flurry */
NSString * const kFlurryAPIKey = @"3DS3N24VRPMPVQYWNYS4";

/**
 * The number of seconds to wait before showing a network activity progress dialog.
 * Currently used by the DownloadProgressBar and PostProgressBar controls.
 */
NSTimeInterval const kNetworkProgressDialogGraceTime = 0.6;

/**
 * The number of seconds that the fade-in animation lasts when displaying documents.
 */
NSTimeInterval const kDocumentFadeInTime = 0.3;

/**
 * The number of seconds that the HUD will de displayed for.
 */
NSTimeInterval const kHUDMinShowTime = 0.7;

/**
 * The number of seconds that the invoked method may be run without
 * showing the HUD.
 */
NSTimeInterval const KHUDGraceTime = 0.2;

//
// General Purpose Constants
//
NSString * const kFDHTTP_Protocol = @"http";
NSString * const kFDHTTPS_Protocol = @"https";
NSString * const kFDHTTP_DefaultPort = @"80";
NSString * const kFDHTTPS_DefaultPort = @"443";

/**
 * The folder name used in the app's Library folder to store the configuration files
 * like the DownloadMetadata
 */
NSString * const kFDLibraryConfigFolderName = @"AppConfiguration";

/**
 * Sync Favorites Preference
 */
NSString * const kSyncedFilesDirectory = @"SyncedDocs";

NSString * const kDefaultAccountsPlist_FileName = @"DefaultAccounts";

/**
 * The number of file suffixes that are tried to avoid file overwrites
 */
unsigned int const kFileSuffixMaxAttempts = 1000;

/**
 * The name of the images used in the UITableViewCells
 */
NSString * const kServerIcon_ImageName = @"server";
NSString * const kImageUIButtonBarBadgeError = @"ui-button-bar-badge-error.png";

/**
 * The default UITableViewCell height
 */
CGFloat const kDefaultTableCellHeight = 60.0f;

/**
 * System Preference Keys
 */
NSString * const kPreferenceApplicationFirstRun = @"FirstRun";

@implementation ODSConstants

@end
