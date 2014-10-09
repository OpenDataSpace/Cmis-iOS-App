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
//  FileProtectionManager.m
//

#import "FileProtectionManager.h"
#import "FileProtectionStrategyProtocol.h"
#import "FileProtectionDefaultStrategy.h"
#import "NoFileProtectionStrategy.h"
#import "ProgressAlertView.h"
//#import "ASIDownloadCache.h"
//#import "AccountManager+FileProtection.h"
#import "FileUtils.h"

static const BOOL isDevelopment = NO;
static BOOL isDataProtectionEnabled = NO;

static NSInteger const kDataProtectionDialogTag = 0;

@interface FileProtectionManager ()
@property (nonatomic, retain) id<FileProtectionStrategyProtocol> strategy;
@property (nonatomic, retain) UIAlertView *dataProtectionDialog;
@end

@implementation FileProtectionManager

+ (void)initialize
{
    if (isDevelopment)
    {
        [[ODSUserDefaults standardUserDefaults] setBool:NO forKey:@"dataProtectionPrompted"];
        [[ODSUserDefaults standardUserDefaults] synchronize];
    }
    
    isDataProtectionEnabled = [[ODSUserDefaults standardUserDefaults] boolForKey:kSettingsDataProtectionIdentifier];
    // Creating the shared instance to initialize the notification observers
    [self sharedInstance];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _progressAlertView = nil;
    _strategy = nil;
    _dataProtectionDialog = nil;

}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDownloadCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDataProtection) name:kKeychainUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

/**
 * Choose a given protection strategy depending if the file protection is enabled or not.
 */
- (id<FileProtectionStrategyProtocol>)selectStrategy
{
    if ([self isFileProtectionEnabled])
    {
        return [[FileProtectionDefaultStrategy alloc] init];
    } 
    return [[NoFileProtectionStrategy alloc] init];
}

- (BOOL)completeProtectionForFileAtPath:(NSString *)path
{
    return [[self selectStrategy] completeProtectionForFileAtPath:path];
}

- (BOOL)completeUnlessOpenProtectionForFileAtPath:(NSString *)path
{
    return [[self selectStrategy] completeUnlessOpenProtectionForFileAtPath:path];
}

- (BOOL)isFileProtectionEnabled
{
    NSString *dataProtectionEnabled = [[ODSUserDefaults standardUserDefaults] objectForKey:@"dataProtectionEnabled"];
    return [dataProtectionEnabled boolValue];
}

- (void)enterpriseAccountDetected
{
    // We show the alert only if the dataProtectionEnabled user preference is not set
    BOOL dataProtectionPrompted = [[ODSUserDefaults standardUserDefaults] boolForKey:@"dataProtectionPrompted"];
    if (!dataProtectionPrompted && !self.dataProtectionDialog)
    {
        self.dataProtectionDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"dataProtection.available.title", @"Data Protection")
                                                                message:NSLocalizedString(@"dataProtection.available.message", @"Data protection is available. Do you want to enable it?")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"No", @"No")
                                                      otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
        [self.dataProtectionDialog setTag:kDataProtectionDialogTag];
        [self.dataProtectionDialog show];
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kDataProtectionDialogTag)
    {
        BOOL dataProtectionEnabled = NO;
        if (buttonIndex != self.dataProtectionDialog.cancelButtonIndex)
        {
            dataProtectionEnabled = YES;
        }
        [[ODSUserDefaults standardUserDefaults] setBool:dataProtectionEnabled forKey:kSettingsDataProtectionIdentifier];
        [[ODSUserDefaults standardUserDefaults] setBool:YES forKey:@"dataProtectionPrompted"];
        [[ODSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Notification methods

- (void)checkDataProtection
{
    BOOL currentDataProtection = [[ODSUserDefaults standardUserDefaults] boolForKey:kSettingsDataProtectionIdentifier];

    // Comparing the current data protection value with the previous data protection value.
    // If the values differ, then loop through and apply protection depending on the appropriate strategy.
    if (currentDataProtection != isDataProtectionEnabled)
    {
        NSString *progressMessage = currentDataProtection ?
            NSLocalizedString(@"dataProtection.protectDownloadsProgress.message", @"Protecting downloaded documents") :
            NSLocalizedString(@"dataProtection.unprotectDownloadsProgress.message", @"Unprotecting downloaded documents");

        ProgressAlertView *alertView = [[ProgressAlertView alloc] initWithMessage:progressMessage];
        [self setProgressAlertView:alertView];
        [alertView setMinTime:1.0f];
        [alertView show];
        
        [FileUtils enumerateSavedFilesUsingBlock:^(NSString *path) {
            [[FileProtectionManager sharedInstance] completeProtectionForFileAtPath:path];
        }];
       
        [alertView hide];
    }
    
    isDataProtectionEnabled = currentDataProtection;
}

/**
 * This manager is responsable of clearing the cache because we want to keep the File Protection
 * related funcionality in this class.
 */
- (void)clearDownloadCache
{
    if ([self isFileProtectionEnabled])
    { //TODO: Need download cahce manager
        //[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
    }
}

+ (FileProtectionManager *)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

@end
