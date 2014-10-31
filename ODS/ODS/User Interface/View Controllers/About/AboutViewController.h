//
//  AboutViewController.h
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *buildTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton *ziaLogoButton;
@property (nonatomic, weak) IBOutlet UIButton *smallZiaButton;

- (IBAction)buttonPressed:(id)sender;
@end
