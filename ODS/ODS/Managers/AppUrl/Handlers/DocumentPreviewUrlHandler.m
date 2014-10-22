//
//  DocumentPreviewUrlHandler.m
//  ODS
//
//  Created by bdt on 10/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DocumentPreviewUrlHandler.h"

static NSString * const PREFIX = @"doc-preview";

@interface DocumentPreviewUrlHandler ()
@property (nonatomic, retain) NSString *urlSchema;

@end

@implementation DocumentPreviewUrlHandler

#pragma mark -
#pragma App URL Handler Delegate
/*
 Returns the URL prefix ("scheme://host") the handler will accept.
 defaultAppScheme will be of the format "scheme://"
 */
- (NSString *)handledUrlPrefix:(NSString *)defaultAppScheme {
    [self setUrlSchema:defaultAppScheme];
    
    return [defaultAppScheme stringByAppendingString:PREFIX];
}

/*
 Performs the operation on the input url.
 i.e. Add an account, handle an incoming file, activate an account.
 */
- (void)handleUrl:(NSURL *)url annotation:(id)annotation {
    ODSLogDebug(@"handleUrl:(NSURL *)url annotation:(id)annotation:%@", url);
}

@end
