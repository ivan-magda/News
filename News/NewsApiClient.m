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

- (void)allSourcesWithSuccess:(nullable void (^)(NSArray * _Nullable sources))success
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
        
        success([self parseSourcesJSON:json]);
    } fail:fail];
}

- (NSArray *)parseSourcesJSON:(NSDictionary *)json {
    return [NewsBuilder buildSourcesFromJSON:json];
}

@end
