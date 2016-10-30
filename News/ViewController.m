//
//  ViewController.m
//  News
//
//  Created by Ivan Magda on 30/10/2016.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

#import "ViewController.h"
#import "NewsApiClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NewsApiClient *client = [NewsApiClient sharedInstance];
    [client allSourcesWithSuccess:^(NSDictionary * _Nonnull json) {
        NSLog(@"Fetched sources:\n%@", json);
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"Failed fetch sources with error: %@", error.localizedDescription);
    }];
}

@end
