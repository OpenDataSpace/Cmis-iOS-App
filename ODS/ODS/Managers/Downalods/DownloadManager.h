//
//  DownloadManager.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AbstractDownloadManager.h"

@interface DownloadManager : AbstractDownloadManager
// Static selector to access DownloadManager singleton
+ (DownloadManager *)sharedManager;
@end
