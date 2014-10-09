//
//  RepositoryNodeViewCell.h
//  ODS
//
//  Created by bdt on 8/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoryNodeViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView    *imgIcon;
@property (nonatomic, weak) IBOutlet UILabel        *lblFileName;
@property (nonatomic, weak) IBOutlet UILabel        *lblDetails;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;
@property (nonatomic, weak) IBOutlet UIImageView    *restrictedImage;  //Not use it at the moment
@end
