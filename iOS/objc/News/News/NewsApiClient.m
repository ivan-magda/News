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

#import "NewsApiClient.h"
#import "NewsBuilder.h"
#import "NewsSource.h"

static NSString * const kApplicationKey = @"4ccf7703d7c84b959e5a1913eedf07e2";
static NSString * const kBaseUrlString = @"https://newsapi.org/v1/";
static NSString * const kErrorDomain = @"NewsApiClient";

@implementation NewsApiClient {
    NSURL *_newsBaseURL;
}

+ (nonnull instancetype)sharedInstance {
    static NewsApiClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        sharedInstance = [[NewsApiClient alloc]initWithConfiguration:config baseURL:kBaseUrlString];
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

- (NSURL *)newsBaseURL {
    if (_newsBaseURL == nil) {
        _newsBaseURL = [NSURL URLWithString: kBaseUrlString];
    }
    return _newsBaseURL;
}

- (void)allSourcesWithSuccess:(nullable void (^)(NSArray * _Nullable sources))success
                         fail:(nullable void (^)(NSError * _Nonnull error))fail {
    NSURL *url = [[self newsBaseURL] URLByAppendingPathComponent: @"sources"];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    if (url == nil) {
        fail([NSError errorWithDomain:kErrorDomain code:10
                             userInfo:@{NSLocalizedDescriptionKey : @"Failed to construct URL."}]);
        return;
    }
    
    [self fetchRawDataForRequest:request success:^(NSData * _Nonnull data) {
        NSDictionary *json = [self jsonObjectFromData: data];
        
        if (json == nil) {
            NSString *message = [NSString stringWithFormat:@"Failed to serialize JSON with data: %@", data];
            fail([NSError errorWithDomain:kErrorDomain code:11
                                 userInfo:@{NSLocalizedDescriptionKey: message}]);
        }
        
        success([self parseSourcesJSON:json]);
    } fail: fail];
}

- (void)articlesForSource:(NewsSource * _Nonnull)source
              withSuccess:(nonnull void (^)(NSArray * _Nullable articles))success
                     fail:(nonnull void (^)(NSError * _Nonnull error))fail {
    NSMutableDictionary *parameters = [@{
                                 @"source": source.identifier,
                                 @"apiKey": kApplicationKey
                                 } mutableCopy];
    if (source.sortTypes.count > 0) parameters[@"sortBy"] = source.sortTypes.firstObject;
    NSURL *URL = [[self newsBaseURL] URLByAppendingPathComponent: @"articles"];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [self buildURLWithBaseURL:URL methodParameters:parameters]];
    
    [self fetchRawDataForRequest:request success:^(NSData * _Nonnull data) {
        NSDictionary *json = [self jsonObjectFromData: data];
        
        if (json == nil) {
            NSString *message = [NSString stringWithFormat:@"Failed to serialize JSON with data: %@", data];
            fail([NSError errorWithDomain:kErrorDomain code:11
                                 userInfo:@{NSLocalizedDescriptionKey: message}]);
        }
        
        success([self parseArticlesJSON: json]);
    } fail: fail];
    
}

- (NSDictionary *)jsonObjectFromData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                           error:&error];
    if (error != nil) {
        NSLog(@"Failed to serialize json: %@", error.localizedDescription);
        return nil;
    }
    
    return json;
}

- (NSArray *)parseSourcesJSON:(NSDictionary *)json {
    return [NewsBuilder buildSourcesFromJSON:json];
}

- (NSArray *)parseArticlesJSON:(NSDictionary *)json {
    return [NewsBuilder buildArticlesFromJSON: json];
}

@end
