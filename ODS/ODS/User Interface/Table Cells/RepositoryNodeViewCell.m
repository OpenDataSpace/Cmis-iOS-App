//
//  RepositoryNodeViewCell.m
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "RepositoryNodeViewCell.h"

NSString * const kRepositoryNodeCellIdentifier = @"RepositoryNodeCellIdentifier";

@implementation RepositoryNodeViewCell
@synthesize isDownloadingPreview = _isDownloadingPreview;

- (void)awakeFromNib
{
    // Initialization code
    [self setIsDownloadingPreview:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsDownloadingPreview:(BOOL)isDownloadingPreview
{
    _isDownloadingPreview = isDownloadingPreview;
    
    if (isDownloadingPreview)
    {
        [self setAccessoryView:[self makeCancelPreviewDisclosureButton]];
    }
    else
    {
        [self setAccessoryView:[self makeDetailDisclosureButton]];
    }
}

- (UIButton *)makeDetailDisclosureButton
{
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIButton *)makeCancelPreviewDisclosureButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"stop-transfer"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    UITableView *currentTableview = (UITableView *) self.superview;
    if (![currentTableview isKindOfClass:[UITableView class]]) {  //add this fixed for ios7
        currentTableview = (UITableView *) currentTableview.superview;
    }
    
    NSIndexPath * indexPath = [currentTableview indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:currentTableview]];
    if (indexPath != nil)
    {
        [currentTableview.delegate tableView:currentTableview accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

@end
