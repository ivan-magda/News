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

private let cellReuseIdentifier = "SourceCell"

final class SourcesTableViewDataSource: NSObject {
    fileprivate var sources = [Source]()
    
    override init() {
        super.init()
    }
    
    init(_ sources: [Source]) {
        self.sources = sources
        super.init()
    }
    
    func update(with newData: [Source]) {
        sources = newData
    }
}

// MARK: - SourcesViewController: UITableViewDataSource -

extension SourcesTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configure(cell, at: indexPath)
    }
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let source = sources[indexPath.row]
        cell.textLabel?.text = source.name
        cell.detailTextLabel?.text = source.category
    }
}

// MARK: - SourcesViewController: UITableViewDelegate -

extension SourcesTableViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select row at index path: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
