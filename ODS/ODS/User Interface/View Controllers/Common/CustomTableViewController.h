//
//  CustomTableViewController.h
//  ODS
//
//  Created by bdt on 8/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "IpadSupport.h"
#import "CustomTableViewCell.h"

@interface CustomTableViewController : UITableViewController <MBProgressHUDDelegate>

//For tableview using static cell
@property (nonatomic, strong)   NSMutableArray  *tableHeaders;
@property (nonatomic, strong)   NSMutableArray  *tableSections;


@property (nonatomic, strong) MBProgressHUD *HUD;

- (void)hudWasHidden:(MBProgressHUD *)hud;
- (void)startHUD;
- (void)stopHUD;
- (void)clearAllHUDs;

- (UITableViewCell*) createTableViewCellFromNib:(NSString*) nibName;
- (CustomTableViewCell*) findeCellByModeIdentifier:(NSString*) modelIdentifier;

- (void)refresh:(id)sender;
- (void) endRefreshing;
@end
