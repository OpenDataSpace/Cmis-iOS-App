//
//  ODSUserDefaults.m
//  ODS
//
//  Created by bdt on 8/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ODSUserDefaults.h"
#import "NSNotificationCenter+CustomNotification.h"

@implementation ODSUserDefaults

- (BOOL)synchronize
{
    [super synchronize];
    [[NSNotificationCenter defaultCenter] postKeychainUserDefaultsDidChangeNotification];
    
    return YES;
}

@end
