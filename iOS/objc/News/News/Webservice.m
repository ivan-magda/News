/**
 * Copyright (c) 2016 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "Webservice.h"

// MARK: Util

typedef void(^Block)();

void performOnMain(Block block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

// MARK: Webservice Extension

@interface Webservice ()

@end

// MARK: - Webservice

@implementation Webservice {
    NSURLSession *_session;
    NSMutableSet *_currentTasks;
}

// MARK: Init

- (nonnull instancetype)initWithConfiguration: (NSURLSessionConfiguration * _Nonnull)configuration
                              baseURL: (NSString * _Nonnull)url {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _baseURL = url;
        _currentTasks = [NSMutableSet new];
    }
    return self;
}

// MARK: Public

- (NSURLSession * _Nonnull)session {
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:_configuration];
    }
    return _session;
}

- (void)cancelAllTasks {
    [_currentTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * _Nonnull task, BOOL * _Nonnull stop) {
        [task cancel];
    }];
    [_currentTasks removeAllObjects];
}

- (void)fetchRawDataForRequest:(NSURLRequest * _Nonnull)request
                       success:(WebserviceSuccessBlock _Nullable)success
                          fail:(WebserviceFailBlock _Nullable)fail {
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request success:^(NSData * _Nonnull data) {
        performOnMain(^{
            success(data);
        });
    } fail:^(NSError * _Nonnull error) {
        performOnMain(^{
            fail(error);
        });
    }];
    [task resume];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest * _Nonnull)request
                                      success:(WebserviceSuccessBlock _Nullable)success
                                      fail:(WebserviceFailBlock _Nullable)fail {
    __block NSURLSessionDataTask *task = nil;
    task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [_currentTasks removeObject: task];
        
        if (error != nil) {
            [self debugLog: [NSString stringWithFormat:@"Received an error from HTTP %@ to %@",
                             request.HTTPMethod, request.URL]];
            fail(error);
            return ;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (httpResponse == nil) {
            [self debugLog: @"Failed on response processing."];
            [self debugLog: [NSString stringWithFormat: @"Error: %@", [error localizedDescription]]];
            fail(error);
            return;
        }
        
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode >= 200 && statusCode <= 299) {
            [self debugLog: [NSString stringWithFormat: @"Status code: %i", (int)statusCode]];
        } else {
            fail(error);
            return;
        }
        [self debugLog: [NSString stringWithFormat: @"Received HTTP %i from %@ to %@",
                         (int)statusCode, request.HTTPMethod, request.URL]];
        
        if (data == nil) {
            fail(error);
            return;
        }
        
        success(data);
    }];
    [_currentTasks addObject:task];
    
    return task;
}

- (NSURL * _Nullable)buildURLWithBaseURL:(NSURL * _Nonnull)baseURL methodParameters:(NSDictionary *_Nullable)parameters {
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL: NO];
    
    if (parameters.count > 0) {
        __block NSMutableArray *queryItems = [NSMutableArray arrayWithCapacity:parameters.count];
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value: obj];
            [queryItems addObject:item];
        }];
        
        components.queryItems = [queryItems copy];
    }
    
    return components.URL;
}

- (void)debugLog: (NSString *)message {
    NSLog(@"%@", message);
}

@end
