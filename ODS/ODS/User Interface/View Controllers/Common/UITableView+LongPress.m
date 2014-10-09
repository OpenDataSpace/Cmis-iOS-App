//
//  UITableView+LongPress.m
//  FreshDocs
//
//  Created by bdt on 11/1/13.
//
//

#import "UITableView+LongPress.h"

@implementation UITableView (LongPress)
@dynamic delegate;

- (void)addLongPressRecognizer {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            // I am not sure why I need to cast here. But it seems to be alright.
            [(id<UITableViewDelegateLongPress>)self.delegate tableView:self didRecognizeLongPressOnRowAtIndexPath:indexPath];
        }
    }
}
@end
