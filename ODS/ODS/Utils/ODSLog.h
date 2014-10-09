/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
//
//  ODSLog.h
//  ODS
//
//  Created by bdt on 8/6/14.
//  Copyright (c) 2014 OpenDataSpace. All rights reserved.
//

/**
 * Convenience macros
 */
#define ODSLogError(...)   [[ODSLog sharedInstance] logError:__VA_ARGS__]
#define ODSLogWarning(...) [[ODSLog sharedInstance] logWarning:__VA_ARGS__]
#define ODSLogInfo(...)    [[ODSLog sharedInstance] logInfo:__VA_ARGS__]
#define ODSLogDebug(...)   [[ODSLog sharedInstance] logDebug:__VA_ARGS__]
#define ODSLogTrace(...)   [[ODSLog sharedInstance] logTrace:__VA_ARGS__]

/**
 * Default logging level
 *
 * The default logging level is Info for release builds and Debug for debug builds.
 * The recommended way to override the default is to #include this header file in your app's .pch file
 * and then redefine the ODS_LOG_LEVEL macro to suit.
 */
#if !defined(ODS_LOG_LEVEL)
#if DEBUG
#define ODS_LOG_LEVEL ODSLogLevelDebug
#else
#define ODS_LOG_LEVEL ODSLogLevelInfo
#endif
#endif

#import <Foundation/Foundation.h>

@interface ODSLog : NSObject

typedef NS_ENUM(NSUInteger, ODSLogLevel)
{
    ODSLogLevelOff = 0,
    ODSLogLevelError,
    ODSLogLevelWarning,
    ODSLogLevelInfo,
    ODSLogLevelDebug,
    ODSLogLevelTrace
};

@property (nonatomic, assign) ODSLogLevel logLevel;

/**
 * Returns the shared singleton
 */
+ (ODSLog *)sharedInstance;

/**
 * Designated initializer. Can be used when not instanciating this class in singleton mode.
 */
- (id)initWithLogLevel:(ODSLogLevel)logLevel;

- (NSString *)stringForLogLevel:(ODSLogLevel)logLevel;

- (void)logErrorFromError:(NSError *)error;
- (void)logError:(NSString *)format, ...;
- (void)logWarning:(NSString *)format, ...;
- (void)logInfo:(NSString *)format, ...;
- (void)logDebug:(NSString *)format, ...;
- (void)logTrace:(NSString *)format, ...;
@end
