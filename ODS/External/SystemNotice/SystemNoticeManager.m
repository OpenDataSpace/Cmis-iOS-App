/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  SystemNoticeManager.m
//

#import "SystemNoticeManager.h"

@interface SystemNoticeManager ()
@property (nonatomic, retain) NSMutableArray *queuedNotices;
@property (nonatomic, retain) SystemNotice *displayingNotice;
@end

@implementation SystemNoticeManager

@synthesize queuedNotices = _queuedNotices;

#pragma mark - Shared Instance

+ (SystemNoticeManager *)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init])
    {
        self.queuedNotices = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    // This singleton object lives for the entire life of the application, so we don't even attempt to dealloc.
    assert(NO);
}

#pragma mark - Instance methods (Public)

- (void)queueSystemNotice:(SystemNotice *)systemNotice
{
    if ([self findSimilarQueuedNotice:systemNotice] == nil)
    {
        [self.queuedNotices addObject:systemNotice];
        [self processNoticeQueue];
    }
}

- (void)systemNoticeDidDisappear:(SystemNotice *)systemNotice
{
    self.displayingNotice = nil;
    [self.queuedNotices removeObject:systemNotice];
    [self processNoticeQueue];
}

#pragma mark - Instance methods (Private)

/**
 * Filter out duplicate error messages. Allow information and warning duplicates.
 */
- (SystemNotice *)findSimilarQueuedNotice:(SystemNotice *)systemNotice
{
    // Active notice
    if (self.displayingNotice.noticeStyle == SystemNoticeStyleError && [systemNotice isEqual:self.displayingNotice])
    {
        return self.displayingNotice;
    }
    
    // Queued notices
    NSArray *queuedNotices = [NSArray arrayWithArray:self.queuedNotices];
    SystemNotice *similarQueuedNotice = nil;
    for (SystemNotice *queued in queuedNotices)
    {
        if ((systemNotice.noticeStyle == SystemNoticeStyleError) && [systemNotice isEqual:queued])
        {
            similarQueuedNotice = queued;
            break;
        }
    }
    return similarQueuedNotice;
}

- (void)processNoticeQueue
{
    if (self.displayingNotice)
    {
        return;
    }
    
    if ([self.queuedNotices count] > 0)
    {
        self.displayingNotice = [self.queuedNotices objectAtIndex:0];
        [self.queuedNotices removeObjectAtIndex:0];
        [self.displayingNotice performSelector:@selector(canDisplay)];
    }
}

@end
