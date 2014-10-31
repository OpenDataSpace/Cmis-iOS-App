//
//  LocalDocument.m
//  ODS
//
//  Created by bdt on 10/30/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "LocalDocument.h"

@implementation LocalDocument

+(LocalDocument *) loacalDocumentWithUrl:(NSString*) url docName:(NSString*)docName {
    LocalDocument *doc = [[LocalDocument alloc] init];
    
    doc.documentURL = url;
    doc.docName = docName;
    
    return doc;
}

@end
