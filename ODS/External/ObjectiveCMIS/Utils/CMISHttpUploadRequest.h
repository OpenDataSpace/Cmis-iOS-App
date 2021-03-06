/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISHttpRequest.h"
@interface CMISHttpUploadRequest : CMISHttpRequest <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, assign) unsigned long long bytesExpected; // optional; if not set, expected content length from HTTP header is used
@property (nonatomic, readonly) unsigned long long bytesUploaded;

/**
 * starts a URL request with a provided input stream. The input stream provided will be used directly to send the data upstream.
 * For this the class sets the HTTPBodyStream property (method) to this input stream. No base64 encoding will be done using this method.
 * completionBlock returns CMISHttpResponse instance or nil if unsuccessful
 */
+ (id)startRequest:(NSMutableURLRequest *)urlRequest
                            httpMethod:(CMISHttpRequestMethod)httpRequestMethod
                           inputStream:(NSInputStream*)inputStream
                               headers:(NSDictionary*)additionalHeaders
                         bytesExpected:(unsigned long long)bytesExpected
                authenticationProvider:(id<CMISAuthenticationProvider>) authenticationProvider
                       completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
                         progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * starts a URL request with a provided input stream. The input stream has to point to the raw NON-encoded data set. This method will first write the 
 * provided start data, afterwards the content of the input stream (optionally encoding it as base64) and then the provided end data.
 */
+ (id)startRequest:(NSMutableURLRequest *)urlRequest
        httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       inputStream:(NSInputStream*)sourceInputStream
           headers:(NSDictionary*)additionalHeaders
     bytesExpected:(unsigned long long)bytesExpected
authenticationProvider:(id<CMISAuthenticationProvider>) authenticationProvider
         startData:(NSData *)startData
           endData:(NSData *)endData
 useBase64Encoding:(BOOL)useBase64Encoding
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
     progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

@end
