//
//  LogoManager.m
//  FreshDocs
//
//  Created by bdt on 3/19/14.
//
//

#import "LogoManager.h"
#import "CMISRepositoryService.h"
#import "CMISRepositoryInfo.h"
#import "CMISPagedResult.h"
#import "CMISFolder.h"
#import "CMISSession.h"
#import "CMISOperationContext.h"
#import "CMISDocument.h"
#import "CMISBinding.h"
#import "FileUtils.h"
#import "AccountManager.h"
#import "AccountInfo+URL.h"
#import "LogoFile.h"

/* logo file name we would use */
NSString * const kLogoAboutZiaLogo_500 = @"aboutLogo-500.png";
NSString * const kLogoAboutZiaLogo = @"aboutLogo.png";
NSString * const kLogoAboutZiaLotoBottom = @"aboutLogoBottom.png";
NSString * const kLogoZiaLogo_60 = @"Logo-60.png";
NSString * const kLogoZiaLogo_144 = @"Logo-144.png";
NSString * const kLogoZiaLogo_240 = @"Logo-240.png";
NSString * const kLogoZiaLogoCP_130 = @"LogoCP-130.png";
NSString * const kLogoZiaLogoCP_260 = @"LogoCP-260.png";
NSString * const kLogoNoDocumentSelected = @"no-document-selected.png";
NSString * const kLogoTabAboutLogo = @"tabAboutLogo.png";
NSString * const KLogoAboutMore = @"about-more.png";

NSString * const kNotificationUpdateLogos = @"NOTIFICATION_UPDATE_LOGOS";


#define IS_RETINA_SCREEN (([[UIScreen mainScreen] scale] > 1.0)?YES:NO)  //if the retina screen, scale will be 2.0 

@interface LogoManager() {
    NSMutableDictionary         *logoFiles_;
    NSString                    *currentAccountUUID_;
}
@end

@implementation LogoManager

+ (LogoManager*) shareManager {
    dispatch_once_t predicate = 0;
    static LogoManager *instanceLogoManager = nil;
    if (instanceLogoManager == nil) {
        dispatch_once(&predicate, ^{
            instanceLogoManager = [[self alloc] init];
        });
    }
    [[UIScreen mainScreen] scale];
    return instanceLogoManager;
}

//init
- (id) init {
    if (self = [super init]) {
        logoFiles_ = [NSMutableDictionary dictionary];
        currentAccountUUID_ = nil;
    }
    
    return self;
}

//set current active account uui
- (void) setCurrentActiveAccount:(NSString*) uuid {
    currentAccountUUID_ = nil;
    currentAccountUUID_ = [uuid copy];
}

//get logo url by name
- (NSURL*) getLogoURLByName:(NSString*) logoName {
    NSMutableDictionary *filesDict = [logoFiles_ objectForKey:currentAccountUUID_];
    NSString *fileName =  logoName;
    
    if (IS_RETINA_SCREEN) {//example: logo.png  ====>  logo@2x.png
        fileName = [[logoName stringByDeletingPathExtension] stringByAppendingString:@"@2x."];
        fileName = [fileName stringByAppendingString:[logoName pathExtension]];
    }
    
    if (filesDict) {
        LogoFile *file = [filesDict objectForKey:fileName];
        if (file) {
            return [NSURL fileURLWithPath:file.fileURL];
        }
    }
    
    return nil;
}

//check logs for account
- (BOOL) isExistLogosForAccount:(NSString*) uuid {
    return (([logoFiles_ objectForKey:uuid] == nil)? NO:YES);
}

- (CMISRepositoryInfo*) findConfigrationRepository:(NSArray*) repos {
    CMISRepositoryInfo *confRepo = nil;
    
    for (CMISRepositoryInfo *repo in repos) {
        if ([repo.name isEqualToCaseInsensitiveString:@"config"]) {
            confRepo = repo;
            break;
        }
    }
    
    return confRepo;
}

//set logo infor for account
- (void) setLogoInfo:(NSArray*) allItems accountUUID:(NSString*) uuid {
    
    CMISRepositoryInfo *confRepo = [self findConfigrationRepository:allItems];
    
    [self loadConfigurationFiles:confRepo acctUUID:uuid];
}

#pragma mark -
#pragma Helper Methods

//CMIS parameters
- (CMISSessionParameters *) getSessionParametersWithAccountInfo:(AccountInfo*) acctInfo repoIdentifier:(NSString*) repoIdentifier {
    CMISSessionParameters *params = nil;
    
    if ([[acctInfo cmisType] integerValue] == CMISBindingTypeAtomPub) {
        params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
        [params setAtomPubUrl:[acctInfo serviceDocumentURL]];
        
    }else if ([[acctInfo cmisType] integerValue] == CMISBindingTypeBrowser) {  //force to use atompub protocol when getting logos
        params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
        [params setAtomPubUrl:[acctInfo serviceAtomDocumentURL]];
    }
    
    params.username  = [acctInfo username];
    params.password = [acctInfo password];
    
    if (repoIdentifier) {
        params.repositoryId = repoIdentifier;
    }
    
    return params;
}

- (void) loadConfigurationFiles:(CMISRepositoryInfo *)repoInfo acctUUID:(NSString*) acctUUID {
    AccountInfo *acctInfo = [[AccountManager sharedManager] accountInfoForUUID:acctUUID];
    CMISSessionParameters *params = [self getSessionParametersWithAccountInfo:acctInfo repoIdentifier:repoInfo.identifier];
    
    [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *session, NSError *sessionError) {
        if (sessionError != nil) {
            ODSLogError(@"%@", sessionError);
        }else {
            [session retrieveRootFolderWithCompletionBlock:^(CMISFolder *folder, NSError *error) {
                if (error) {
                    ODSLogError(@"%@", error);
                }else {
                    CMISOperationContext *opContext = [CMISOperationContext defaultOperationContext];
                    opContext.depth = -1;
                    //opContext.maxItemsPerPage = 1000;
                    [folder retrieveDescendantsWithOperationContext:opContext completionBlock:^(CMISPagedResult* results, NSError *error) {
                        if (error) {
                            ODSLogError(@"retrieveChildrenWithCompletionBlock:%@", error);
                        }else {
                            //check changetoken first
                            if (![self deleteOldLogo:results.resultArray accountUUID:acctUUID]) {
                                [self storeLogoFileList:results.resultArray accountUUID:acctUUID];
                                [self broadcastUpdateLogosNotification:acctUUID];
                                return ;
                            };
                            for (CMISObject *item in results.resultArray) {
                                if (isCMISFolder(item)) {
                                    continue;
                                }
                                CMISDocument *doc = (CMISDocument*) item;
                                if (![self isIOSLogos:doc]) {
                                    continue;
                                }
                                
                                if ([self isLogoFileExists:doc accountUUID:acctUUID]) {
                                    continue;
                                }
                                __block BOOL bComplete = NO;
                                [doc downloadContentToFile:[self logoFilePathWithObject:doc accountUUID:acctUUID] completionBlock:^(NSError *error) {
                                    bComplete = YES;
                                    if (error) {
                                        ODSLogError(@"%@", error);
                                    }else {
                                        [self storeLogoFile:doc accountUUID:acctUUID];
                                        [self broadcastUpdateLogosNotification:acctUUID];
                                    }
                                } progressBlock:nil];
                                //waiting for downloading finish
                                while (!bComplete) {
                                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                                }
                            }
                        }
                    }];                    
                }
            }];
        }
    }];
}

- (NSString*) logoFilePathWithObject:(CMISDocument*) doc accountUUID:(NSString*) acctUUID {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",[doc.name stringByDeletingPathExtension], doc.changeToken, [doc.name pathExtension]];
    return [FileUtils pathToLogoFile:fileName accountUUID:acctUUID];
}

- (BOOL) isLogoFileExists:(CMISDocument*) doc accountUUID:(NSString*) acctUUID {
    NSString *filePath = [self logoFilePathWithObject:doc accountUUID:acctUUID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        unsigned long long sizeOfFile = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
        if (sizeOfFile == doc.contentStreamLength) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) deleteOldLogo:(NSArray*) items accountUUID:(NSString*) acctUUID {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *logoDirPath = [FileUtils pathToLogoFile:@"" accountUUID:acctUUID];
    
    NSError *error;
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:logoDirPath error:&error];
    if (error) {
        ODSLogError(@"%@", error);
        return YES;
    }
    
    if ([items count] == 0 || [fileList count] == 0) {
        return YES;
    }
    
    //find any ios logo
    CMISDocument *anyDoc = nil;
    for (CMISDocument *doc in items) {
        if ([self isIOSLogos:doc]) {
            anyDoc = doc;
            break;
        }
    }
    
    NSString *fileName = nil;
    for (NSString *file in fileList) {
        if ([file hasPrefix:[anyDoc.name stringByDeletingPathExtension]]) {
            fileName = file;
            break;
        }
    }
    
    if (![[fileName stringByDeletingPathExtension] hasSuffix:anyDoc.changeToken]) {
        [fileMgr removeItemAtPath:logoDirPath error:&error];
        if (error) {
            ODSLogError(@"Delete directory %@:%@", logoDirPath, error);
        }
        
        return YES;
    }
    
    return NO;
}

- (void) storeLogoFile:(CMISDocument*) doc accountUUID:(NSString*) acctUUID {
    NSMutableDictionary *logos = [logoFiles_ objectForKey:acctUUID];
    if (logos == nil) {
        logos = [NSMutableDictionary dictionary];
        [logoFiles_ setObject:logos forKey:acctUUID];
    }
    
    LogoFile *file = [[LogoFile alloc] init];
    
    file.fileName = doc.name;
    file.fileSize = [NSNumber numberWithLongLong:doc.contentStreamLength];
    file.changeToken = doc.changeToken;
    file.fileURL = [self logoFilePathWithObject:doc accountUUID:acctUUID];
    [logos setObject:file forKey:doc.name];
}

- (void) storeLogoFileList:(NSArray*) fileList accountUUID:(NSString*) acctUUID {
    for (CMISObject *item in fileList) {
        if (isCMISFolder(item)) {
            continue;
        }
        CMISDocument *doc = (CMISDocument*) item;
        if (![self isIOSLogos:doc]) {
            continue;
        }
        
        [self storeLogoFile:doc accountUUID:acctUUID];
    }
}

- (BOOL) isIOSLogos:(CMISDocument*) doc {
    if ([doc.name hasPrefix:[kLogoAboutZiaLogo_500 stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoAboutZiaLogo stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoAboutZiaLotoBottom stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoZiaLogo_60 stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoZiaLogo_144 stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoZiaLogo_240 stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoZiaLogoCP_130 stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoZiaLogoCP_260 stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoNoDocumentSelected stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[kLogoTabAboutLogo stringByDeletingPathExtension]]
        || [doc.name hasPrefix:[KLogoAboutMore stringByDeletingPathExtension]]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Private Method
//broadcast notification update logos
- (void) broadcastUpdateLogosNotification:(NSString*) accountUUID {
    if (currentAccountUUID_ && [accountUUID isEqualToString:currentAccountUUID_]) {  //send notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateLogos object:nil]; //may placeholder viewcontroller had been created. we have to update the logo for it.
    }
}

@end
