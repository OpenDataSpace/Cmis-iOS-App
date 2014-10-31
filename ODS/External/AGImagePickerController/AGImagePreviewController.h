//
//  AGImagePreviewController.h
//  Araneo
//
//  Created by SpringOx on 14-10-23.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AGImagePickerControllerDefines.h"

@interface AGImagePreviewController : UIViewController

@property (ag_weak, readonly) UIImage *image;

- (id)initWithImage:(UIImage *)image;

@end
