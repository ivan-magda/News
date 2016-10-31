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

#import "SourcesTableViewController.h"
#import "DataDirector.h"
#import "NewsSource.h"
#import "NewsSourceEmptyDataSourceView.h"
#import "ArticlesTableViewController.h"

static NSString * const kCellReuseIdentifier = @"SourceCell";
static NSString * const kShowNewsArticlesSegueIdentifier = @"NewsArticles";

@interface SourcesTableViewController ()

@end

@implementation SourcesTableViewController {
    NSArray *_sources;
    
    UIRefreshControl *_refreshControl;
    NewsSourceEmptyDataSourceView *_emptyDataSourceView;
}

#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(_dataDirector != nil, @"DataDirector must exist.");
    [self configure];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: kShowNewsArticlesSegueIdentifier]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NewsSource *source = _sources[selectedIndexPath.row];
        
        ArticlesTableViewController *detailVC = (ArticlesTableViewController *)segue.destinationViewController;
        detailVC.selectedSource = source;
        detailVC.dataDirector = _dataDirector;
    }
}

#pragma mark Private Helpers

- (void)configure {
    _sources = [_dataDirector.sources copy];
    _emptyDataSourceView = [[NewsSourceEmptyDataSourceView alloc]initWithFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:kDataDirectorDidUpdateSourcesNotificationName object:nil];
    
    self.tableView.refreshControl = [UIRefreshControl new];
    [self.tableView.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
}

- (void)updateData {
    [self.tableView.refreshControl endRefreshing];
    _sources = [_dataDirector.sources copy];
    
    if (self.tableView.backgroundView == nil) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
}

- (void)fetchData {
    [_dataDirector reloadNewsSources];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    if (_sources.count > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numberOfSections = 1;
        self.tableView.backgroundView = nil;
    } else {
        self.tableView.backgroundView = _emptyDataSourceView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NewsSource *source = _sources[indexPath.row];
    cell.textLabel.text = source.name;
    cell.detailTextLabel.text = source.category;
}

@end
