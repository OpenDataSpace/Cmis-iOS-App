//
//  LocalDocument.h
//  ODS
//
//  Created by bdt on 10/30/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalDocument : NSObject
@property (nonatomic, copy) NSString *documentURL;
@property (nonatomic, copy) NSString *docName;

+(LocalDocument *) loacalDocumentWithUrl:(NSString*) url docName:(NSString*)docName;
@end
