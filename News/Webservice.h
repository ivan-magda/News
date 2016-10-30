//
//  Webservice.h
//  News
//
//  Created by Ivan Magda on 30/10/2016.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WebserviceSuccessBlock)(NSData * _Nonnull data);
typedef void(^WebserviceFailBlock)(NSError * _Nonnull error);

@interface Webservice : NSObject

@property (nonatomic, strong, readonly) NSURLSessionConfiguration * _Nonnull configuration;
@property (nonatomic, strong, readonly) NSString * _Nonnull baseURL;

- (nonnull instancetype)initWithConfiguration: (NSURLSessionConfiguration * _Nonnull)configuration
                              baseURL: (NSString * _Nonnull)url;

- (NSURLSession * _Nonnull)session;
- (void)cancelAllTasks;

- (void)fetchRawDataForRequest:(NSURLRequest * _Nonnull)request
                       success:(WebserviceSuccessBlock _Nullable)success
                          fail:(WebserviceFailBlock _Nullable)fail;

@end
