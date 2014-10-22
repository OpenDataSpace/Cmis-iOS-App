//
//  BarButtonBadge.m
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

#import "BarButtonBadge.h"
#import "CustomBadge.h"


@implementation BarButtonBadge

+(UIBarButtonItem *)barButtonWithImage:(UIImage *)buttonImage badgeString:(NSString *)string atRight:(BOOL)atRightSideOfScreen toTarget:(id)target action:(SEL)action {
	CustomBadge *badge = [CustomBadge customBadgeWithString:string];
	CGRect badgeFrame;
	if (!atRightSideOfScreen) {
		badgeFrame = CGRectMake(20.0f, 0.0f, badge.frame.size.width, badge.frame.size.height);
	} else {
		badgeFrame = CGRectMake((-badge.frame.size.width) + 5, 0.0f, badge.frame.size.width, badge.frame.size.height);
	}
	[badge setFrame:badgeFrame];
	
	UIButton *badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	badgeButton.frame = CGRectMake(0, 0, 30, 30);
	[badgeButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	[badgeButton setImage:buttonImage forState:UIControlStateNormal];
	[badgeButton addSubview:badge];
	
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:badgeButton];
	return barButton;
}

@end
