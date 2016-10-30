//
//  NewsApiClient.m
//  News
//
//  Created by Ivan Magda on 30/10/2016.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

#import "NewsApiClient.h"

static NSString * const kApplicationKey = @"4ccf7703d7c84b959e5a1913eedf07e2";
static NSString * const kBaseURL = @"https://newsapi.org/v1/";

@implementation NewsApiClient

+ (nonnull instancetype)sharedInstance {
    static NewsApiClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        sharedInstance = [[NewsApiClient alloc]initWithConfiguration:config baseURL:kBaseURL];
    });
    return sharedInstance;
}

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration
                              baseURL:(NSString *)url {
    self = [super initWithConfiguration:configuration baseURL:url];
    if (self) {
        self.configuration.timeoutIntervalForRequest = 30.0;
        self.configuration.timeoutIntervalForResource = 60.0;
    }
    return self;
}

- (void)allSourcesWithSuccess:(nullable void (^)(NSDictionary * _Nonnull json))success
                         fail:(nullable void (^)(NSError * _Nonnull error))fail {
    NSURL *url = [NSURL URLWithString:@"sources" relativeToURL:[NSURL URLWithString:self.baseURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    if (url == nil) {
        fail([NSError errorWithDomain:@"NewsApiClient" code:10
                             userInfo:@{NSLocalizedDescriptionKey : @"URL is nil"}]);
        return;
    }
    
    [self fetchRawDataForRequest:request success:^(NSData * _Nonnull data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error != nil) {
            NSLog(@"Failed to fetch sources: %@", error.localizedDescription);
            fail(error);
            return ;
        }
        
        success(json);
    } fail:fail];
}

@end
