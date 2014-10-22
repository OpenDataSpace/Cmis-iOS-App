//
//  IpadSupport.h
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DetailNavigationController;

@interface IpadSupport : NSObject

+ (void)clearDetailController;

+ (void)registerGlobalDetail:(DetailNavigationController *)newDetailController;

// Handles the presentation as a modal controller in the ipad and a normal push
// to a nav controller in the iphone
+ (void)presentModalViewController:(UIViewController *)newController withNavigation:(UINavigationController *)navController;

+ (void)pushDetailController:(UIViewController *)newController withNavigation:(UINavigationController *)navController andSender:(id)sender;

+ (NSString *)getCurrentDetailViewControllerObjectID;
+ (NSURL *)getCurrentDetailViewControllerFileURL;
+ (void)showMasterPopover;
@end
