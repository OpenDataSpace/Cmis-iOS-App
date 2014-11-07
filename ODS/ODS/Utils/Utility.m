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
//  Utility.m
//

#import "Utility.h"
#import "ISO8601DateFormatter.h"
#import "AppDelegate.h"
#import "AccountManager.h"
#import "AccountInfo+URL.h"
#import "CMISConstants.h"
#import "DetailNavigationController.h"
#import "DownloadManager.h"
#import "LocalFileManager.h"
#import "CMISStandardUntrustedSSLAuthenticationProvider.h"

#import <sys/xattr.h>

static NSDictionary *iconMappings;
static NSDictionary *mimeMappings;
static NSDictionary *apiKeys;

UIImage *imageForFilename(NSString *filename)
{
    NSString *fileExtension = filename.pathExtension;
    if (fileExtension && (fileExtension.length > 0))
    {
        NSString *potentialImageName = [fileExtension stringByAppendingPathExtension:@"png"];
        UIImage *potentialImage = [UIImage imageNamed:potentialImageName];
        if (nil != potentialImage)
        {
            return potentialImage;
        }
    }
    
	NSString *imageName = nil;
    if (!iconMappings)
    {
        NSString *mappingsPath = [[NSBundle mainBundle] pathForResource:@"IconMappings" ofType:@"plist"];
        iconMappings = [[NSDictionary alloc] initWithContentsOfFile:mappingsPath];
    }
	NSUInteger location = [filename rangeOfString:@"." options:NSBackwardsSearch].location;
	if (location != NSNotFound)
    {
		NSString *ext = [[filename substringFromIndex:location] lowercaseString];
		if ([iconMappings objectForKey:ext])
        {
			imageName = [iconMappings objectForKey:ext];
		}
	}
    
    if (imageName == nil || imageName.length == 0)
    {
        imageName = @"generic.png";
    }
    
	return [UIImage imageNamed:imageName];
}

NSString *mimeTypeForFilename(NSString *filename)
{
    return mimeTypeForFilenameWithDefault(filename, @"application/octet-stream");//@"text/plain"); Issue 3792
}

NSString *mimeTypeForFilenameWithDefault(NSString *filename, NSString *defaultMimeType)
{
    NSString *fileExtension = filename.pathExtension.lowercaseString;
    NSString *mimeType = defaultMimeType;
    
    if (!mimeMappings)
    {
        NSString *mimeMappingsPath = [[NSBundle mainBundle] pathForResource:@"MimeMappings" ofType:@"plist"];
        mimeMappings = [[NSDictionary alloc] initWithContentsOfFile:mimeMappingsPath];
    }
    
    if (fileExtension && (fileExtension.length > 0) && [mimeMappings objectForKey:fileExtension])
    {
        mimeType = [mimeMappings objectForKey:fileExtension];
    }
    
    return mimeType;
}

#pragma mark -
#pragma mark File Type Utility

BOOL isVideoExtension(NSString *extension)
{
    static NSArray *videoExtensions = nil;
    extension = [extension lowercaseString];
    
    if (!videoExtensions)
    {
        videoExtensions = [NSArray arrayWithObjects:@"mov", @"mp4", @"mpv", @"3gp", @"m4v", nil];
    }
    
    return [videoExtensions containsObject:extension];
}

BOOL isAudioExtension(NSString *extension)
{
    static NSArray *audioExtensions;
    extension = [extension lowercaseString];
    
    if (!audioExtensions)
    {
        //From http://stackoverflow.com/questions/4461898/getting-file-type-audio-or-video-in-ios
        audioExtensions = [NSArray arrayWithObjects:@"mp3", @"m4p", @"m4a", @"aac", @"wav", @"caf", nil];
    }
    
    return [audioExtensions containsObject:extension];
}

BOOL isIWorkExtension(NSString *extension)
{
    static NSArray *iWorkExtensions;
    extension = [extension lowercaseString];
    
    if (!iWorkExtensions)
    {
        iWorkExtensions = [NSArray arrayWithObjects:@"key", @"pages", @"numbers", nil];
    }
    
    return [iWorkExtensions containsObject:extension];
}

BOOL isPhotoExtension(NSString *extension)
{
    static NSArray *photoExtensions = nil;
    extension = [extension lowercaseString];
    
    if (!photoExtensions)
    {
        photoExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"bmp", @"tiff", @"tif", @"gif", nil];
    }
    
    return [photoExtensions containsObject:extension];
}

BOOL isMimeTypeVideo(NSString *mimeType)
{
    return [[mimeType lowercaseString] hasPrefix:@"video/"];
}

#pragma mark -
#pragma mark CMIS Utilities
//CMIS Allow action
BOOL isAllowAction(CMISObject* fileObj, CMISActionType actionType) {
    
    if (fileObj && [[fileObj.allowableActions allowableActionTypesSet] containsObject:[NSNumber numberWithInteger:actionType]]) {
        return YES;
    }
    
    return NO;
}

BOOL isCMISFolder(CMISObject* fileObj) {
    if ([fileObj.objectType isEqualToCaseInsensitiveString:kCMISPropertyObjectTypeIdValueFolder]) {
        return YES;
    }
    
    return NO;
}

//CMIS parameters
CMISSessionParameters * getSessionParametersWithAccountInfo(AccountInfo* acctInfo, NSString* repoIdentifier) {
    CMISSessionParameters *params = nil;
    
    if ([[acctInfo cmisType] integerValue] == CMISBindingTypeAtomPub) {
        params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
        [params setAtomPubUrl:[acctInfo serviceDocumentURL]];
        
    }else if ([[acctInfo cmisType] integerValue] == CMISBindingTypeBrowser) {
        params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeBrowser];
        [params setBrowserUrl:[acctInfo serviceDocumentURL]];
    }
    
    params.username  = [acctInfo username];
    
    params.password = [acctInfo password];
    
    if ([acctInfo.protocol isEqualToCaseInsensitiveString:kFDHTTPS_Protocol] && !userPrefValidateSSLCertificate()) {
        params.authenticationProvider = [[CMISStandardUntrustedSSLAuthenticationProvider alloc] initWithUsername:[acctInfo username] password:[acctInfo password]];
    }
    
    if (repoIdentifier) {
        params.repositoryId = repoIdentifier;
    }
    
    return params;
}

CMISSessionParameters * getSessionParametersWithAccountUUID(NSString* acctUUID, NSString* repoIdentifier) {
    AccountInfo* acctInfo = [[AccountManager sharedManager] accountInfoForUUID:acctUUID];
    
    return getSessionParametersWithAccountInfo(acctInfo, repoIdentifier);
}

#pragma mark -
#pragma mark Network Spinner
static int spinnerCount = 0;

void startSpinner()
{
	if (spinnerCount <= 0)
    {
		spinnerCount = 0;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	spinnerCount++;
}

void stopSpinner()
{
	spinnerCount--;
	if (spinnerCount <= 0)
    {
		spinnerCount = 0;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

#pragma mark -
#pragma mark Settings Utility
BOOL userPrefShowHiddenFiles()
{
	return [[ODSUserDefaults standardUserDefaults] boolForKey:kSettingsShowHiddenFilesIdentifier];
}

BOOL userPrefValidateSSLCertificate()
{
	return [[ODSUserDefaults standardUserDefaults] boolForKey:kSettingsValidateSSLCertIdentifier];
}

BOOL userPrefResetOnNextStart(void) {
    return [[ODSUserDefaults standardUserDefaults] boolForKey:kSettingsResetOnNextStartIdentifier];
}

#pragma mark -
#pragma mark Date Utility
NSDate*dateFromIso(NSString *isoDate)
{
	ISO8601DateFormatter *isoFormatter = [[ISO8601DateFormatter alloc] init];
    NSDate *formattedDate = [isoFormatter dateFromString:isoDate];
	return formattedDate;
}

NSString *formatDateTime(NSString *isoDate)
{
	if (nil == isoDate)
    {
		return @"";
	}
	
	NSDate *date = dateFromIso(isoDate);
	return formatDateTimeFromDate(date);
}

NSString *formatDateTimeFromDate(NSDate *dateObj)
{
	if (nil == dateObj)
    {
		return @"";
	}
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
	NSString *humanReadableDate = [dateFormatter stringFromDate:dateObj];
	return humanReadableDate;
}

// Is "useRelativeDate" Setting aware
NSString *changeStringDateToFormat(NSString *stringDate, NSString *currentFormat, NSString *destinationFormat)
{
	if (nil == stringDate)
    {
		return @"";
	}
	
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    BOOL useRelativeDate = [[ODSUserDefaults standardUserDefaults] boolForKey:@"useRelativeDate"];
    [currentFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [currentFormatter setDateFormat:currentFormat];
    NSDate *date = [currentFormatter dateFromString:stringDate];
    NSString *formattedDate;
    
    if (useRelativeDate)
    {
        formattedDate = relativeDateFromDate(date);
    }
    else
    {
        NSDateFormatter *destinationFormatter = [[NSDateFormatter alloc] init];
        [destinationFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [destinationFormatter setDateFormat:destinationFormat];
        formattedDate = [destinationFormatter stringFromDate:date];
    }
    
	return formattedDate;
}

NSString *relativeDate(NSString *isoDate)
{
    if (nil == isoDate)
    {
		return @"";
	}
    
	NSDate *convertedDate = dateFromIso(isoDate);
    return relativeDateFromDate(convertedDate);
}

NSString *relativeDateFromDate(NSDate *objDate)
{
    if (nil == objDate)
    {
		return @"";
	}
    
    NSDate *todayDate = [NSDate date];
    double ti = [objDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    
    NSString *key = nil;
    int diff = 0;
    
    if (ti < 1)
    {
        key = @"relative.date.just-now";
    }
    else if (ti < 60)
    {
        key = @"relative.date.less-than-a-minute-ago";
    }
    else if (ti < 3600)
    {
        diff = round(ti / 60);
        key = (diff > 1) ? @"relative.date.n-minutes-ago" : @"relative.date.one-minute-ago";
    }
    else if (ti < 86400)
    {
        diff = round(ti / 60 / 60);
        key = (diff > 1) ? @"relative.date.n-hours-ago" : @"relative.date.one-hour-ago";
    }
    else
    {
        diff = round(ti / 60 / 60 / 24);
        key = (diff > 1) ? @"relative.date.n-days-ago" : @"relative.date.one-day-ago";
    }
    
    return [NSString stringWithFormat:NSLocalizedString(key, @"Localized relative date string"), diff];
}

NSString *relativeIntervalFromSeconds(NSTimeInterval seconds)
{
    NSString *timeFormat = nil;
    int diff = 0;
    
    if (seconds > (60 * 60 * 24))
    {
        diff = seconds / 60 / 60 / 24;
        timeFormat = (diff > 1) ? @"relative.interval.n-days" : @"relative.interval.one-day";
    }
    else if (seconds > (60 * 60))
    {
        diff = seconds / 60 / 60;
        timeFormat = (diff > 1) ? @"relative.interval.n-hours" : @"relative.interval.one-hour";
    }
    else if (seconds > 60)
    {
        diff = seconds / 60;
        timeFormat = (diff > 1) ? @"relative.interval.n-minutes" : @"relative.interval.one-minute";
    }
    else
    {
        diff = seconds;
        timeFormat = (diff > 1) ? @"relative.interval.n-seconds" : @"relative.interval.one-second";
    }
    
    return [NSString stringWithFormat:NSLocalizedString(timeFormat, @"Localized relative date string"), diff];
}

// Is "useRelativeDate" Setting aware
NSString *formatDocumentDate(NSString *isoDate)
{
    BOOL useRelativeDate = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseRelativeDateIdentifier];
    
    if (useRelativeDate)
    {
        return relativeDate(isoDate);
    }
    return formatDateTime(isoDate);
}

// Is "useRelativeDate" Setting aware
NSString *formatDocumentDateFromDate(NSDate *dateObj)
{
    BOOL useRelativeDate = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseRelativeDateIdentifier];
    
    if (useRelativeDate)
    {
        return relativeDateFromDate(dateObj);
    }
    return formatDateTimeFromDate(dateObj);
}


#pragma mark -
#pragma mark MBProgressHUD Utility
/**
 * Utility methods to help make our use of MBProgressHUD more consistent
 */

MBProgressHUD *createProgressHUDForView(UIView *view)
{
    // Protecting the app when we try to initialize a HUD and the view is not init'd yet
    if(!view)
    {
        return nil;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud setTaskInProgress:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setMinShowTime:kHUDMinShowTime];
    [hud setGraceTime:KHUDGraceTime];
	[view addSubview:hud];
    
    return hud;
}

MBProgressHUD *createAndShowProgressHUDForView(UIView *view)
{
    MBProgressHUD *hud = createProgressHUDForView(view);
    [hud show:YES];
    return hud;
}

void stopProgressHUD(MBProgressHUD *hud)
{
    [hud setTaskInProgress:NO];
    [hud setDelegate:nil];
    [hud hide:YES];
}

#pragma mark -
#pragma mark System Notice Utility
/**
 * Notice Messages
 */
SystemNotice *displayErrorMessage(NSString *message)
{
    return displayErrorMessageWithTitle(message, nil);
}

SystemNotice *displayErrorMessageWithTitle(NSString *message, NSString *title)
{
    return [SystemNotice showErrorNoticeInView:activeView() message:message title:title];
}

SystemNotice *displayWarningMessageWithTitle(NSString *message, NSString *title)
{
    return [SystemNotice showWarningNoticeInView:activeView() message:message title:title];
}

SystemNotice *displayInformationMessage(NSString *message)
{
    return [SystemNotice showInformationNoticeInView:activeView() message:message];
}

UIView *activeView(void)
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DetailNavigationController *detailNavigation = (DetailNavigationController *)[[(UISplitViewController *)appDelegate.mainViewController viewControllers] objectAtIndex:1];
    if (appDelegate.mainViewController.presentedViewController)
    {
        //To work around a system notice that is tried to be presented in a modal view controller
        return appDelegate.mainViewController.presentedViewController.view;
    }
    else if (IS_IPAD)
    {
        if (detailNavigation.masterPopoverController.popoverVisible)
        {
            // Work around for displaying the alert on top of the UIPopoverView in Portrait mode
            return appDelegate.mainViewController.view.superview;
        }
        else if (detailNavigation.isExpanded)
        {
            return detailNavigation.view;
        }
    }
    return appDelegate.mainViewController.view;
}

//shared ALAssetsLibrary
ALAssetsLibrary *defaultAssetsLibrary() {
    return [AGImagePickerController defaultAssetsLibrary];
}

ALAsset *assetFromURL(NSURL* assetURL) {
    __block ALAsset *assetObj = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        ALAssetsLibrary *library = defaultAssetsLibrary();
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                assetObj = asset;
            }
            dispatch_semaphore_signal(semaphore);
        } failureBlock:^(NSError *error) {
            ODSLogError(@"Counld not crate asset from assetURL:%@. Error %@", [assetURL absoluteString], error);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return assetObj;
}

void styleButtonAsDefaultAction(UIBarButtonItem *button)
{
    UIColor *actionColor = [UIColor colorWithHue:0.61 saturation:0.44 brightness:0.9 alpha:1.0];
    [button setTintColor:actionColor];
}

void styleButtonAsDestructiveAction(UIBarButtonItem *button)
{
    UIColor *actionColor = [UIColor colorWithHue:0 saturation:0.80 brightness:0.71 alpha:0];
    [button setTintColor:actionColor];
}


extern NSString *const NSURLIsExcludedFromBackupKey __attribute__((weak_import));

BOOL addSkipBackupAttributeToItemAtURL(NSURL *URL)
{
    BOOL returnValue = NO;
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.1"))
    {
        const char *filePath = [[URL path] fileSystemRepresentation];
        const char *attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        returnValue = (result == 0);
    }
    else
    {
        NSError *error = nil;
        returnValue = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    }
    
    return returnValue;
}

//get storyboard instance
UIStoryboard *instanceMainStoryboard() {
    return [UIStoryboard storyboardWithName:IS_IPAD?kMainStoryboardNameiPad:kMainStoryboardNameiPhone bundle:nil];
}

NSString *externalAPIKey(APIKey apiKey)
{
    if (!apiKeys)
    {
        // We could use an NSArray here, but the binding between enum value and array index would be weak
        apiKeys = [[NSDictionary alloc] initWithObjectsAndKeys:
                   @"ODS_FLURRY_API_KEY", [NSNumber numberWithInt:APIKeyFlurry],
                   @"", [NSNumber numberWithInt:APIKeyQuickoffice],
                   nil];
    }
    return [apiKeys objectForKey:[NSNumber numberWithInt:apiKey]];
}

BOOL isFileDownloaded(CMISObject* fileObj) {
    NSString *downloadKey = [LocalFileManager downloadKeyWithObject:fileObj];
    if ([[DownloadManager sharedManager] isManagedDownload:downloadKey]) {
        return YES;
    }
    
    if ([[LocalFileManager sharedInstance] downloadExistsForKey:downloadKey]) {
        return YES;
    }
    
    return NO;
}
