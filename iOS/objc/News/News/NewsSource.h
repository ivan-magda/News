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

#import <Foundation/Foundation.h>

@class NewsSourceLogo;

@interface NewsSource : NSObject

@property (nonatomic) NSString * _Nonnull identifier;
@property (nonatomic) NSString * _Nonnull name;
@property (nonatomic) NSString * _Nonnull detail;
@property (nonatomic) NSString * _Nonnull url;
@property (nonatomic) NSString * _Nonnull category;
@property (nonatomic) NewsSourceLogo * _Nonnull logos;
@property (nonatomic, readonly) NSArray * _Nonnull sortTypes;

- (nonnull instancetype)initWithIdentifier:(NSString * _Nonnull)identifier
                                      name:(NSString * _Nonnull)name
                                    detail:(NSString * _Nonnull)detail
                                       url:(NSString * _Nonnull)url
                                  category:(NSString * _Nonnull)category
                                     logos:(NewsSourceLogo * _Nonnull)logos
                         availableSortTypes:(NSArray * _Nonnull)sortTypes;

@end
