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
#import "Source.h"
#import "SourceLogo.h"
#import "Article.h"

@implementation NewsBuilder

#pragma mark NewsSource

+ (nonnull NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [NSDateFormatter new];
        sharedInstance.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        sharedInstance.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    });

    return sharedInstance;
}

+ (Source *_Nullable)buildSourceFromJSON:(NSDictionary *_Nonnull)json {
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

    SourceLogo *logo = [[SourceLogo alloc] initWithSmallURL:smallURL mediumURL:mediumURL
                                                   largeURL:largeURL];

    return [[Source alloc] initWithIdentifier:identifier
                                         name:name
                                       detail:detail
                                          url:url
                                     category:category
                                        logos:logo
                           availableSortTypes:sortTypes];
}

+ (NSArray *_Nullable)buildSourcesFromJSON:(NSDictionary *_Nonnull)json {
    NSDictionary *jsonCopy = [json copy];
    NSMutableArray *sources = [NSMutableArray arrayWithCapacity:60];

    NSArray *jsonSources = jsonCopy[@"sources"];
    [jsonSources enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        Source *newsSource = [NewsBuilder buildSourceFromJSON:obj];
        [sources addObject:newsSource];
    }];

    return [sources copy];
}

#pragma mark NewsArticle

+ (Article *_Nullable)buildArticleFromJSON:(NSDictionary *_Nonnull)json {
    NSString *author = json[NSStringFromSelector(@selector(author))];
    NSString *title = json[NSStringFromSelector(@selector(title))];
    NSString *detail = json[@"description"];
    NSString *urlString = json[NSStringFromSelector(@selector(url))];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *dateString = json[@"publishedAt"];

    if (detail == (id) [NSNull null]) {
        detail = @"";
    }

    NSDate *date = nil;
    if (dateString == (id) [NSNull null]) {
        date = [NSDate date];
    } else {
        date = [[self sharedDateFormatter] dateFromString:dateString];
    }

    if (author == nil || title == nil || detail == nil || url == nil || date == nil) {
        NSLog(@"%@", @"Failed parse some part of the JSON.");
    }

    return [[Article alloc] initWithAuthor:author title:title detail:detail url:url publishDate:date];
}

+ (NSArray *_Nullable)buildArticlesFromJSON:(NSDictionary *_Nonnull)json {
    NSDictionary *jsonCopy = [json copy];
    NSMutableArray *sources = [NSMutableArray arrayWithCapacity:60];

    NSArray *jsonSources = jsonCopy[@"articles"];
    [jsonSources enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        Article *article = [self buildArticleFromJSON:obj];
        [sources addObject:article];
    }];

    return [sources copy];
}

@end
