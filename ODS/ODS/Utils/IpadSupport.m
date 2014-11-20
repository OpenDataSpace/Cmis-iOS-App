//
//  IpadSupport.m
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "IpadSupport.h"
#import "CustomNavigationController.h"
#import "DetailNavigationController.h"
#import "AppDelegate.h"
#import "ModalViewControllerProtocol.h"
#import "PlaceholderViewController.h"
#import "NSNotificationCenter+CustomNotification.h"
#import "DocumentViewController.h"
#import "MetadataViewController.h"

@implementation IpadSupport

DetailNavigationController *detailController;

+ (void)clearDetailController
{
    if (detailController != nil)
    {
        if (detailController.fullScreenModalController != nil)
        {
            [detailController performCloseAction:nil];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboardNameiPad bundle:nil];
            PlaceholderViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PlaceholderControllerIdentifier"];
            [IpadSupport pushDetailController:viewController withNavigation:nil andSender:nil dismissPopover:NO];
        }
    }
}

+ (void)registerGlobalDetail:(DetailNavigationController *)newDetailController
{
    detailController = newDetailController;
}

+ (void)pushDetailController:(UIViewController *)newController withNavigation:(UINavigationController *)navController andSender:(id)sender
{
    [self pushDetailController:newController withNavigation:navController andSender:sender dismissPopover:YES];
}

+ (void)pushDetailController:(UIViewController *)newController withNavigation:(UINavigationController *)navController andSender:(id)sender dismissPopover:(BOOL)dismiss
{
    [self pushDetailController:newController withNavigation:navController andSender:sender dismissPopover:dismiss showFullScreen:NO];
}

+ (void)pushDetailController:(UIViewController *)newController withNavigation:(UINavigationController *)navController andSender:(id)sender
              dismissPopover:(BOOL)dismiss showFullScreen:(BOOL) fullScreen
{
    // In the case the navigation bar was hidden by a viewController
    [detailController setNavigationBarHidden:NO animated:YES];
    
    if (IS_IPAD && detailController != nil && newController != nil)
    {
        [detailController.detailViewController didReceiveMemoryWarning];
        [detailController resetViewControllerStackWithNewTopViewController:newController dismissPopover:dismiss];
        [detailController.detailViewController viewDidUnload];
        
        if (fullScreen == YES)
        {
            [detailController showFullScreen];
        }
        
//        // Extract the current document's metadata (fileMetadata) if the controller supports that property and it's non-nil
//        DownloadMetadata *fileMetadata = nil;
//        if ([newController respondsToSelector:@selector(fileMetadata)])
//        {
//            fileMetadata = [newController performSelector:@selector(fileMetadata)];
//        }
//        
        NSDictionary *userInfo = [NSMutableDictionary dictionary];
        if(sender != nil)
        {
            [userInfo setValue:sender forKey:@"newDetailController"];
        }
        
//        if (fileMetadata != nil)
//        {
//            // Non-nil metadata, so use the optional userInfo dictionary with the notification
//            [userInfo setValue:fileMetadata forKey:@"fileMetadata"];
//        }
        
        [[NSNotificationCenter defaultCenter] postDetailViewControllerChangedNotificationWithSender:sender userInfo:userInfo];
    }
    else
    {
        [navController pushViewController:newController animated:YES];
    }
}

+ (void)presentModalViewController:(UIViewController *)newController withNavigation:(UINavigationController *)navController
{
    if (IS_IPAD || navController == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CustomNavigationController *newNavigation = [[CustomNavigationController alloc] initWithRootViewController:newController];
        newNavigation.modalPresentationStyle = newController.modalPresentationStyle;
        newNavigation.modalTransitionStyle = newController.modalTransitionStyle;
        [appDelegate presentModalViewController:newNavigation animated:YES];
    }else {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *newNavigation = [[UINavigationController alloc] initWithRootViewController:newController];
        newNavigation.modalPresentationStyle = newController.modalPresentationStyle;
        newNavigation.modalTransitionStyle = newController.modalTransitionStyle;
        [appDelegate presentModalViewController:newNavigation animated:YES];
    }
    
    if ([newController conformsToProtocol:@protocol(ModalViewControllerProtocol)])
    {
        UIViewController<ModalViewControllerProtocol> *modalController = (UIViewController<ModalViewControllerProtocol> *) newController;
        modalController.presentedAsModal = YES;
    }
}

+ (NSString *)getCurrentDetailViewControllerObjectID
{
    NSString *objectID = nil;
    id viewController = [detailController.childViewControllers lastObject];
    
    if ([viewController isKindOfClass:[DocumentViewController class]])
    {
        objectID = [((DocumentViewController *)viewController) cmisObjectId];
    }
    else if ([viewController isKindOfClass:[MetadataViewController class]])
    {
        objectID = [[((MetadataViewController *)viewController) cmisObject] identifier];
    }
    
    return objectID;
}

+ (NSString *)getCurrentDetailViewControllerAccountUUID {
    NSString *acctUUID = nil;
    id viewController = [detailController.childViewControllers lastObject];
    
    if ([viewController isKindOfClass:[DocumentViewController class]])
    {
        acctUUID = [((DocumentViewController *)viewController) selectedAccountUUID];
    }
    else if ([viewController isKindOfClass:[MetadataViewController class]])
    {
        acctUUID = [((MetadataViewController *)viewController) selectedAccountUUID];
    }
    
    return acctUUID;
}

+ (NSURL *)getCurrentDetailViewControllerFileURL
{
    NSURL *fileURL = nil;
    
//    if ([detailController.detailViewController isKindOfClass:[DocumentViewController class]])
//    {
//        fileURL = [NSURL fileURLWithPath:[((DocumentViewController *)detailController.detailViewController) filePath]];
//    }
    
    return fileURL;
}

+ (void)showMasterPopover
{
    [detailController showMasterPopoverController];
}

@end
