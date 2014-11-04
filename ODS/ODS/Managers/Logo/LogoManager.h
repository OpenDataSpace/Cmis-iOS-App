//
//  LogoManager.h
//  FreshDocs
//
//  Created by bdt on 3/19/14.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kLogoAboutZiaLogo_500;
extern NSString * const kLogoAboutZiaLogo;
extern NSString * const kLogoAboutZiaLotoBottom;
extern NSString * const kLogoZiaLogo_60 ;
extern NSString * const kLogoZiaLogo_144;
extern NSString * const kLogoZiaLogo_240;
extern NSString * const kLogoZiaLogoCP_130;
extern NSString * const kLogoZiaLogoCP_260;
extern NSString * const kLogoNoDocumentSelected;
extern NSString * const kLogoTabAboutLogo;
extern NSString * const KLogoAboutMore;

extern NSString * const kNotificationUpdateLogos;

@interface LogoManager : NSObject

+ (LogoManager*) shareManager;

//set current active account uuid
- (void) setCurrentActiveAccount:(NSString*) uuid;

//get logo url by name
- (NSURL*) getLogoURLByName:(NSString*) logoName;

//check if has logo information.
- (BOOL) isExistLogosForAccount:(NSString*) uuid;

//set logo infor for account
- (void) setLogoInfo:(NSArray*) allItems accountUUID:(NSString*) uuid;
@end
