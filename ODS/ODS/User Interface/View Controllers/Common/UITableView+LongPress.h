//
//  UITableView+LongPress.h
//  FreshDocs
//
//  Created by bdt on 11/1/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UITableViewDelegateLongPress;

@interface UITableView (LongPress) <UIGestureRecognizerDelegate>
@property(nonatomic,assign)   id <UITableViewDelegateLongPress>   delegate;
- (void)addLongPressRecognizer;
@end


@protocol UITableViewDelegateLongPress <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didRecognizeLongPressOnRowAtIndexPath:(NSIndexPath *)indexPath;
@end
