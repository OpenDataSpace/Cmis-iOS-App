//
//  AGIPCGridCell.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCGridCell.h"
#import "AGIPCGridItem.h"

#import "AGImagePickerController.h"
#import "AGImagePickerController+Helper.h"

@interface AGIPCGridCell ()
{
	NSArray *_items;
    AGImagePickerController *_imagePickerController;
}

@end

@implementation AGIPCGridCell

#pragma mark - Properties

@synthesize items = _items, imagePickerController = _imagePickerController;

- (void)setItems:(NSArray *)items
{
    if (_items != items)
    {
        for (AGIPCGridItem *view in _items)//[self subviews])
        {
            if ([view isKindOfClass:[AGIPCGridItem class]]){                
                [view removeFromSuperview];
            }
        }
        
        _items = items;
    }
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController items:(NSArray *)items andReuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self)
    {
        self.imagePickerController = imagePickerController;
		self.items = items;
        
        UIView *emptyView = [[UIView alloc] init];
        self.backgroundView = emptyView;
	}
	
	return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGRect frame = self.imagePickerController.itemRect;
    CGFloat leftMargin = frame.origin.x;
    
	for (AGIPCGridItem *gridItem in self.items)
    {	
		[gridItem setFrame:frame];
        UITapGestureRecognizer *selectionGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:gridItem action:@selector(tap)];
        selectionGestureRecognizer.numberOfTapsRequired = 1;
		[gridItem addGestureRecognizer:selectionGestureRecognizer];
		[self addSubview:gridItem];
		
		frame.origin.x = frame.origin.x + frame.size.width + leftMargin;
	}
}

@end
