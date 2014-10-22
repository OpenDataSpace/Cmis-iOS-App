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
//  ImageActionSheet.m
//

#import "ImageActionSheet.h"

CGFloat const kMaxImageWidth = 30.0f;
CGFloat const kButtonLeftPadding = 10.0f;
CGFloat const kButtonRightPadding = 10.0f;

@interface UIActionSheet (TableViewDelegate)
/*
 Added the category to avoid compiler warnings: "super may not respond to..."
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ImageActionSheet
@synthesize images = _images;

- (void)dealloc
{
    _images = nil;
}

- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitlesAndImages:(NSString *)firstTitle, ... 
{
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:10];
    if(firstTitle)
    {
        [titles addObject:firstTitle];
    }
    
    va_list titlesImages;
    va_start(titlesImages, firstTitle);
    id value;
    NSInteger index = 0;
    //The first title is in the "firstTitle" parameter
    //The first value of the var args is a UIImage
    while(firstTitle && (value = va_arg( titlesImages, id)) )
    {
        NSInteger mod = index % 2;
        if([value isKindOfClass:[NSString class]] && mod == 1)
        {
            [titles addObject:value];
        }
        else if([value isKindOfClass:[UIImage class]] && mod == 0)
        {
            [images addObject:value];
        }
        else 
        {
            ODSLogDebug(@"ERROR - Incorrectly initialized ImageActionSheet");
            [NSException raise:@"Incorrectly initialized ImageActionSheet" format:@"Expected NSString or UIImages only and in the correct order"];
        }
        index++;
    }
    va_end(titlesImages);

    if([titles count] != [images count])
    {
        ODSLogDebug(@"ERROR - Incorrectly initialized ImageActionSheet");
        [NSException raise:@"Incorrectly initialized ImageActionSheet" format:@"Incorrect number of parameters"];
    }
    
    self = [self initWithTitle:title delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    if(self)
    {
        _images = [[NSMutableDictionary alloc] init];
        for(NSInteger titleIndex = 0; index < [titles count]; index++)
        {
            NSString *buttonTitle = [titles objectAtIndex:titleIndex];
            UIImage *buttonImage = [images objectAtIndex:titleIndex];
            [self addButtonWithTitle:buttonTitle andImage:buttonImage];
        }
    }

    return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title andImage:(UIImage *)image
{
    [self.images setObject:image forKey:title];
    return [self addButtonWithTitle:title];
}

- (void)addImage:(UIImage *)image toButtonIndex:(NSInteger)buttonIndex
{
    [self addImage:image toButtonWithTitle:[self buttonTitleAtIndex:buttonIndex]];
}

- (void)addImage:(UIImage *)image toButtonWithTitle:(NSString *)buttonTitle
{
    [self.images setObject:image forKey:buttonTitle];
}

/*
 We will search for UIButtons in the subview of this ActionSheet
 In the case we find a button with a title as a key for button image
 we add a UIImageView to that button and align the button text to the left
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    for (id subview in [self subviews])
    {
        if([subview isKindOfClass:[UIButton class]])
        {
            UIButton *actionButton = (UIButton *)subview;
            NSString *cancelButtonTitle = [self buttonTitleAtIndex:[self cancelButtonIndex]];
            
            //We don't want any customization for the cancel button
            if(![[actionButton titleForState:UIControlStateNormal] isEqualToString:cancelButtonTitle])
            {
                [subview setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [actionButton setTitleEdgeInsets:UIEdgeInsetsMake(0, kMaxImageWidth + kButtonLeftPadding + kButtonRightPadding, 0, 0)];
                
                UIView *currentView = [actionButton viewWithTag:777];
                if(!currentView)
                {
                    UIImage *image = [self.images objectForKey:[actionButton titleForState:UIControlStateNormal]];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    [imageView setTag:777];
                    CGRect imageFrame = [imageView frame];
                    imageFrame.origin.x = kButtonLeftPadding;
                    /** Warning: Magic values that work for current iOS versions and devices */
                    imageFrame.origin.y = IS_IPAD ? 6.0 : 8.0;
                    imageFrame.size.width = kMaxImageWidth;
                    imageFrame.size.height = kMaxImageWidth;
                    [imageView setFrame:imageFrame];
                    [actionButton addSubview:imageView];
                }
            }
        }
    }
}

/*
 A UITableView is used to display the ActionSheet options only in the iPhone in landscape orientation.
 Overriding this delegate method 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    for(id subview in [cell subviews])
    {
        if([subview isKindOfClass:[UILabel class]])
        {
            UIImage *image = [self.images objectForKey:[subview text]];
            if(image)
            {
                [cell.imageView setImage:image];
                break;
            }
        }
    }

    return cell;
}

/*
 Changing the position of the cell title at this point assures us that the custom code that aligns the text to the center
 is overridden with a left alignment
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    for(id subSubview in [cell subviews])
    {
        if([subSubview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subSubview;
            [label setTextAlignment:NSTextAlignmentLeft];
            CGRect labelRect = [label frame];
            labelRect.origin.x += kMaxImageWidth + kButtonLeftPadding + kButtonRightPadding;
            [label setFrame:labelRect];
        }
    }
}

@end
