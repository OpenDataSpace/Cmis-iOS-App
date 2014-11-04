//
//  AboutViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AboutViewController.h"
#import "LogoManager.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:NSLocalizedString(@"about.view.title", @"ODS")];
    
    NSString *versionLabel = [NSString stringWithFormat:@"Ver %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [self.buildTimeLabel setText:versionLabel];
    //set notification for update logo
    [self updateLogos];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:kNotificationUpdateLogos object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.opendataspace.com"]];
}

- (void) handleNotification:(NSNotification*) noti {
    if ([noti.name isEqualToString:kNotificationUpdateLogos]) {
        [self updateLogos];
    }
}

- (void) updateLogos {
    NSURL *ziaLogoURL = [[LogoManager shareManager] getLogoURLByName:IS_IPAD?kLogoZiaLogo_240:kLogoZiaLogoCP_130];
    UIImage *ziaLogoImage = nil;
    if(ziaLogoURL) {
        ziaLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:ziaLogoURL]];
    }else {
        ziaLogoImage = [UIImage imageNamed:[IS_IPAD?kLogoZiaLogo_240:kLogoZiaLogoCP_130 stringByDeletingPathExtension]];
    }
    [self.ziaLogoButton setImage:ziaLogoImage forState:UIControlStateNormal];
    
    if (IS_IPAD) {
        NSURL *ziaSmallLogoURL = [[LogoManager shareManager] getLogoURLByName:kLogoZiaLogoCP_130];
        UIImage *ziaSmallLogoImage = nil;
        if(ziaSmallLogoURL && IS_IPAD) {
            ziaSmallLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:ziaLogoURL]];
        }else {
            ziaSmallLogoImage = [UIImage imageNamed:[kLogoZiaLogoCP_130 stringByDeletingPathExtension]];
        }
        [self.smallZiaButton setImage:ziaSmallLogoImage forState:UIControlStateNormal];
    }
}
@end
