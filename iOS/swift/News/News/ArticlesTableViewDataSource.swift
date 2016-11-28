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

import UIKit

private let cellReuseIdentifier = "ArticleCell"

// MARK: SourcesTableViewDataSource: NSObject

final class ArticlesTableViewDataSource: NSObject {
    
    // MARK: Properties
    
    var didSelect: ((Article) -> ())? = { _ in }
    fileprivate var articles = [Article]()
    
    // MARK: Init
    
    override init() {
        super.init()
    }
    
    init(_ sources: [Article]) {
        self.articles = sources
        super.init()
    }
    
    // MARK: Public
    
    func update(with newData: [Article]) {
        articles = newData
    }
    
}

// MARK: - ArticlesTableViewDataSource: UITableViewDataSource -

extension ArticlesTableViewDataSource: UITableViewDataSource {
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configure(cell, at: indexPath)
    }
    
    // MARK: Private
    
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let article = articles[indexPath.row]
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = ArticlesTableViewDataSource.dateFormatter.string(from: article.publishDate)
    }
    
}

// MARK: - ArticlesTableViewDataSource: UITableViewDelegate -

extension ArticlesTableViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelect?(articles[indexPath.row])
    }
}
