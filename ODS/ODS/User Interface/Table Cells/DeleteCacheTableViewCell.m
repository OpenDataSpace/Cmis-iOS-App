//
//  DeleteCacheTableViewCell.m
//  ODS
//
//  Created by bdt on 10/22/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DeleteCacheTableViewCell.h"

@implementation DeleteCacheTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        //UITableViewCellStyleSubtitle
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        
        [self.detailTextLabel setTextAlignment:NSTextAlignmentCenter];
        [self.detailTextLabel setTextColor:[UIColor whiteColor]];
        
        [self setBackgroundColor:[UIColor redColor]];
    }
    
    return self;
}

@end
