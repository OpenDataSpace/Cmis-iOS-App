//
//  AudioRecorderTableViewCell.h
//  ODS
//
//  Created by bdt on 9/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioRecorderTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel    *lableTitle;
@property (nonatomic, weak) IBOutlet UIButton   *buttonRecord;
@property (nonatomic, weak) IBOutlet UIButton   *buttonPlay;
@end
