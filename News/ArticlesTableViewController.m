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

#import "ArticlesTableViewController.h"
#import "NewsSource.h"
#import "NewsArticle.h"
#import "DataDirector.h"
#import "ArticleViewController.h"

static NSString * const kCellReuseIdentifier = @"ArticleCell";
static NSString * const kShowArticleSegueIdentifier = @"ShowArticle";

@interface ArticlesTableViewController ()

@end

@implementation ArticlesTableViewController {
    NSArray *_articles;
    NSDateFormatter *_dateFormatter;
}

#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(_dataDirector != nil, @"DataDirector must be instantiated.");
    NSAssert(_selectedSource != nil, @"NewsSource must be selected.");
    
    [self configure];
}

- (void)configure {
    self.title = _selectedSource.name;
    self.tableView.refreshControl = [UIRefreshControl new];
    [self.tableView.refreshControl addTarget:self action:@selector(fetchData)
                            forControlEvents:UIControlEventValueChanged];
    [self fetchData];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowArticleSegueIdentifier]) {
        NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
        NewsArticle *selectedArticle = _articles[selectedRow.row];
        
        ArticleViewController *detailVC = (ArticleViewController *)segue.destinationViewController;
        detailVC.article = selectedArticle;
    }
}

#pragma mark Working with data

- (void)fetchData {
    __weak ArticlesTableViewController *weakSelf = self;
    [_dataDirector.dataSource articlesForSource: _selectedSource withSuccess:^(NSArray * _Nonnull news) {
        [weakSelf updateDataSourceWithNewData: news];
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"Failed fetch artciles with error: %@", error.localizedDescription);
        [weakSelf showAlertWithTitle: @"Error" message: @"Failed to load articles."];
        [weakSelf.tableView.refreshControl endRefreshing];
    }];
}

- (void)updateDataSourceWithNewData:(NSArray *)articles {
    _articles = [articles copy];
    [self.tableView.refreshControl endRefreshing];
    [self.tableView reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationAutomatic];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath: indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NewsArticle *article = _articles[indexPath.row];
    cell.textLabel.text = article.title;
    cell.detailTextLabel.text = [[self dateFormatter] stringFromDate:article.publishDate];
}

#pragma mark Private Helpers

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    return _dateFormatter;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: nil]];
    [self presentViewController:alert animated: true completion: nil];
}

@end
