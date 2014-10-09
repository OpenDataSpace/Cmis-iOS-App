//
//  UploadsManager.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AbstractUploadsManager.h"

@interface UploadsManager : AbstractUploadsManager

// Static selector to access this class singleton instance
+ (id)sharedManager;

@end
