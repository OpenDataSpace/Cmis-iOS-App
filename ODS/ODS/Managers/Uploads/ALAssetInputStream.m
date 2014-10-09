//
//  ALAssetInputStream.m
//  ODS
//
//  Created by bdt on 8/29/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "ALAssetInputStream.h"

@interface ALAssetInputStream()
@property (nonatomic, assign) NSUInteger              mPosition;  //current read position
@property (nonatomic, strong) ALAsset                 *mAsset;    //ALAsset Object
@property (nonatomic, strong) ALAssetRepresentation   *mAssetRepresentation;
@property (nonatomic, assign) NSStreamStatus          mStreamStatus;
@end

@implementation ALAssetInputStream

/**
 *  Init input stream with alasset
 *
 *  @param asset alasset from asset library
 *
 *  @return ALAssetInputStream
 */
- (id) initWithALAsset:(ALAsset*) asset {
    if (self = [super init]) {
        self.mPosition = 0;
        self.mAsset = asset;
        self.mAssetRepresentation = [asset defaultRepresentation];
        self.mStreamStatus = NSStreamStatusNotOpen;
    }
    
    return self;
}

/**
 *  Read data
 *
 *  @param buffer buffer to store data
 *  @param len    Max size of read length
 *
 *  @return length of data
 */
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
    
    //check if the stream has more data to read.
    if (![self hasBytesAvailable]) {
        ODSLogDebug(@"hasBytesAvailable======");
        return 0;
    }
    
    NSUInteger remainLen = [self lengthOfRemaining];
    NSUInteger readLen = remainLen > len? len: remainLen;
    
    NSUInteger buffered = 0;
    
    @try {
        //read data
        NSError *error = nil;
        buffered = [self.mAssetRepresentation getBytes:buffer fromOffset:self.mPosition length:readLen error:&error];
        if (error) {
            ODSLogError(@"read asset stream:%@", error);
        }else {
            self.mPosition += buffered;
            if (self.mPosition == [self.mAssetRepresentation size]) {
                self.mStreamStatus = NSStreamStatusAtEnd;
            }
        }
    }
    @catch (NSException *exception) {
        ODSLogError(@"%@", exception);
    }
    ODSLogDebug(@"asset stream ======%d", buffered);
    
    return buffered;
}

/**
 *  Please don't use it.
 */
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len {
    ODSLogError(@"Not implement, please don't use it.");
    return NO;
}

/**
 *  Check if the stream has more data
 *
 *  @return YES if has more data not read or NO
 */
- (BOOL)hasBytesAvailable {
    if (self.mStreamStatus == NSStreamStatusOpen || self.mStreamStatus == NSStreamStatusReading) {
        return ([self.mAssetRepresentation size] > self.mPosition);
    }
    
    return NO;
}

/**
 *  Get the status of stream
 *
 *  @return stream status
 */
- (NSStreamStatus)streamStatus {
    return self.mStreamStatus;
}

/**
 *  Open Stream
 */
- (void)open {
    if (self.mStreamStatus == NSStreamStatusNotOpen) {
        self.mStreamStatus = NSStreamStatusOpen;  //we just set status to be open
    }
}

/**
 *  Close Stream
 */
- (void)close {
    self.mStreamStatus = NSStreamStatusClosed;  //we just set status to be close
}

/**
 *  Get the error of stream, not implement it at the moment.
 *
 *  @return current error
 */
- (NSError *)streamError {
    return nil;
}

/**
 *  Not support to get property by key
 */
- (id)propertyForKey:(NSString *)key {
    ODSLogError(@"Not support to get property by key.");
    return nil;
}

/**
 *  Not support to set property with key
 */
- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    ODSLogError(@"Not support to set property with key.");
    return NO;
}

#pragma mark -
#pragma mark Private Method

- (NSUInteger) lengthOfRemaining {
    if ([self hasBytesAvailable]) {
        return ([self.mAssetRepresentation size] - self.mPosition);
    }
    
    return 0;
}

@end
