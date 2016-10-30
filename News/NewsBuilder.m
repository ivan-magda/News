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

#import "NewsBuilder.h"
#import "NewsSource.h"
#import "NewsSourceLogo.h"

@implementation NewsBuilder

+ (NewsSource * _Nullable)buildFromJSON:(NSDictionary * _Nonnull)json {
    NSString *identifier = json[@"id"];
    NSString *name = json[NSStringFromSelector(@selector(name))];
    NSString *detail = json[NSStringFromSelector(@selector(description))];
    NSString *url = json[NSStringFromSelector(@selector(url))];
    NSString *category = json[NSStringFromSelector(@selector(category))];
    NSArray *sortTypes = json[@"sortBysAvailable"];
    
    NSDictionary *logos = json[@"urlsToLogos"];
    NSString *smallURL = logos[NSStringFromSelector(@selector(small))];
    NSString *mediumURL = logos[NSStringFromSelector(@selector(medium))];
    NSString *largeURL = logos[NSStringFromSelector(@selector(large))];
    
    if (identifier == nil || name == nil || detail == nil || url == nil || category == nil ||
        smallURL == nil || mediumURL == nil || largeURL == nil || sortTypes == nil) {
        NSLog(@"Failed parse some part of the JSON.");
    }
    
    NewsSourceLogo *logo = [[NewsSourceLogo alloc]initWithSmallURL:smallURL mediumURL:mediumURL
                                                          largeURL:largeURL];
    
    return [[NewsSource alloc] initWithIdentifier:identifier
                                             name:name
                                           detail:detail
                                              url:url
                                         category:category
                                            logos:logo
                                availableSortTypes:sortTypes];
}

+ (NSArray * _Nullable)buildSourcesFromJSON:(NSDictionary * _Nonnull)json {
    NSDictionary *jsonCopy = [json copy];
    NSMutableArray *sources = [NSMutableArray arrayWithCapacity:60];
    
    NSArray *jsonSources = jsonCopy[@"sources"];
    [jsonSources enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NewsSource *newsSource = [NewsBuilder buildFromJSON:obj];
        [sources addObject:newsSource];
    }];
    
    return [sources copy];
}

@end
