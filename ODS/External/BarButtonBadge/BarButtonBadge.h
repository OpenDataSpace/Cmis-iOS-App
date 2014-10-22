//
//  BarButtonBadge.h
//  BarButtonBadgeExample
//
/*
*** License & Copyright ***
Created by Justin Amberson http://iosiddqd.blogspot.com on 01/2011. 
Version 1.0
This tiny class can be used for free in private and commercial applications.
Please feel free to modify, extend or distribute this class. 
If you modify: Please distribute under the original license.
A commercial distribution of this class is not allowed.
 */

#import <Foundation/Foundation.h>


@interface BarButtonBadge : NSObject {

}

//Provide a UIImage for the barButtonItem.
//Works best with a square image
//String object displays as the badge text
//BOOL atRightSideOfScreen will position badge on the left side of the button
//target is the object in charge of handling button taps
//action is the selector for the method that will fire when tapped

+(UIBarButtonItem *)barButtonWithImage:(UIImage *)buttonImage badgeString:(NSString *)string atRight:(BOOL)atRightSideOfScreen toTarget:(id)target action:(SEL)action;
//Usage : UIBarButtonItem *barItem = [BarButtonBadge barButtonWithImage:imageObject badgeString:stringObject atRight:NO toTarget:self action:@selector(buttonPressed)];
//barItem is autoReleased so please retain or add to a toolbar.

@end
