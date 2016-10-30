//
//  Webservice.m
//  News
//
//  Created by Ivan Magda on 30/10/2016.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

#import "Webservice.h"

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
        dispatch_async(dispatch_get_main_queue(), ^{
            success(data);
        });
    } fail:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)debugLog: (NSString *)message {
    NSLog(@"%@", message);
}

@end
