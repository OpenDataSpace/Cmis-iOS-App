//
//  LogoFile.h
//  ODS
//
//  Created by bdt on 11/2/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogoFile : NSObject
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *changeToken;
@property (nonatomic, assign) NSNumber  *fileSize;
@property (nonatomic, copy) NSString *fileURL;  //local path
@end
