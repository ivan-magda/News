//
//  NewsApiClient.h
//  News
//
//  Created by Ivan Magda on 30/10/2016.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Webservice.h"

@interface NewsApiClient : Webservice

+ (nonnull instancetype)sharedInstance;
- (void)allSourcesWithSuccess:(nullable void (^)(NSDictionary * _Nonnull json))success
                         fail:(nullable void (^)(NSError * _Nonnull error))fail;

@end
