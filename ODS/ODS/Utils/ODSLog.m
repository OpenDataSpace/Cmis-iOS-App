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
//  ODSLog.m
//  ODS
//
//  Created by bdt on 8/6/14.
//  Copyright (c) 2014 OpenDataSpace. All rights reserved.
//

#import "ODSLog.h"

@implementation ODSLog
@synthesize logLevel = _logLevel;

/**
 * Returns the shared singleton
 */
+ (ODSLog *)sharedInstance {
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

- (id)init
{
    return [self initWithLogLevel:ODS_LOG_LEVEL];
}
/**
 * Designated initializer. Can be used when not instanciating this class in singleton mode.
 */
- (id)initWithLogLevel:(ODSLogLevel)logLevel {
    self = [super init];
    if (self)
    {
        _logLevel = logLevel;
    }
    return self;
}

#pragma mark - 
#pragma mark Info methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Log level: %@", [super description], [self stringForLogLevel:self.logLevel]];
}

- (NSString *)stringForLogLevel:(ODSLogLevel)logLevel
{
    NSString *result = nil;
    
    switch(logLevel)
    {
        case ODSLogLevelOff:
            result = @"OFF";
            break;
        case ODSLogLevelError:
            result = @"ERROR";
            break;
        case ODSLogLevelWarning:
            result = @"WARN";
            break;
        case ODSLogLevelInfo:
            result = @"INFO";
            break;
        case ODSLogLevelDebug:
            result = @"DEBUG";
            break;
        case ODSLogLevelTrace:
            result = @"TRACE";
            break;
        default:
            result = @"UNKNOWN";
    }
    
    return result;
}

#pragma mark -
#pragma mark Logging methods
- (void)logErrorFromError:(NSError *)error{
    if (self.logLevel != ODSLogLevelOff)
    {
        NSString *message = [NSString stringWithFormat:@"[%ld] %@", (long)error.code, error.localizedDescription];
        [self logMessage:message forLogLevel:ODSLogLevelError];
    }
}

- (void)logError:(NSString *)format, ...
{
    if (self.logLevel != ODSLogLevelOff)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:ODSLogLevelError];
    }
}

- (void)logWarning:(NSString *)format, ...
{
    if (self.logLevel >= ODSLogLevelWarning)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:ODSLogLevelWarning];
    }
}

- (void)logInfo:(NSString *)format, ...
{
    if (self.logLevel >= ODSLogLevelInfo)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:ODSLogLevelInfo];
    }
}

- (void)logDebug:(NSString *)format, ...
{
    if (self.logLevel >= ODSLogLevelDebug)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:ODSLogLevelDebug];
    }
}

- (void)logTrace:(NSString *)format, ...
{
    if (self.logLevel == ODSLogLevelTrace)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:ODSLogLevelTrace];
    }
}

#pragma mark - 
#pragma mark Helper methods

- (void)logMessage:(NSString *)message forLogLevel:(ODSLogLevel)logLevel
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:2]];
    NSLog(@"%@ %@ %@", [self stringForLogLevel:logLevel], callingMethod, message);
}

- (NSString *)methodNameFromCallStack:(NSString *)topOfStack
{
    NSString *methodName = nil;
    
    if (topOfStack != nil)
    {
        NSRange startBracketRange = [topOfStack rangeOfString:@"[" options:NSBackwardsSearch];
        if (NSNotFound != startBracketRange.location)
        {
            NSString *start = [topOfStack substringFromIndex:startBracketRange.location];
            NSRange endBracketRange = [start rangeOfString:@"]" options:NSBackwardsSearch];
            if (NSNotFound != endBracketRange.location)
            {
                methodName = [start substringToIndex:endBracketRange.location + 1];
            }
        }
    }
    
    return methodName;
}

@end
