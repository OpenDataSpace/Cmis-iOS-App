//
//  PlaceholderViewController.m
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "PlaceholderViewController.h"
#import "AppDelegate.h"
#import "LogoManager.h"

@interface PlaceholderViewController ()
@end

@implementation PlaceholderViewController
@synthesize noDocImgView = _noDocImgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.noDocLabel setText:NSLocalizedString(@"no.document.selected.text", @"NO Document Selected")];
    [_noDocImgView setImageWithURL:[[LogoManager shareManager] getLogoURLByName:kLogoNoDocumentSelected] placeholderImage:[UIImage imageNamed:kLogoNoDocumentSelected]];
    //set notification for update logo
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:kNotificationUpdateLogos object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Handle Notification

- (void) handleNotification:(NSNotification*) noti {
    if ([noti.name isEqualToString:kNotificationUpdateLogos]) {
        [_noDocImgView setImageWithURL:[[LogoManager shareManager] getLogoURLByName:kLogoNoDocumentSelected] placeholderImage:[UIImage imageNamed:kLogoNoDocumentSelected]];
    }
}
@end
