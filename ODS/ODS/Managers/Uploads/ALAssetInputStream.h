//
//  ALAssetInputStream.h
//  ODS
//
//  Created by bdt on 8/29/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

@interface ALAssetInputStream : NSInputStream

/**
 *  Init input stream with alasset
 *
 *  @param asset alasset from asset library
 *
 *  @return ALAssetInputStream
 */
- (id) initWithALAsset:(ALAsset*) asset;

@end
