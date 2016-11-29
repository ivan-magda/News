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

private enum SegueIdentifier: String {
    case showArticles = "ShowArticles"
}

// MARK: SourcesViewController: UIViewController

final class SourcesViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var newsWebservice: NewsWebservice!
    
    fileprivate let dataSource = SourcesTableViewDataSource()
    fileprivate var sources = [Source]()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case SegueIdentifier.showArticles.rawValue:
            let selectedSource = sender as! Source
            
            let articlesVC = segue.destination as! ArticlesViewController
            articlesVC.newsWebservice = newsWebservice
            articlesVC.source = selectedSource
        default:
            assert(false, "Unexpected segue.")
        }
    }
    
    // MARK: Private
    
    private func configure() {
        tableView.dataSource = dataSource;
        tableView.delegate = dataSource;
        
        weak var weakSelf = self
        dataSource.didSelect = weakSelf?.showSource
    }
    
    private func showSource(_ source: Source) {
        performSegue(withIdentifier: SegueIdentifier.showArticles.rawValue, sender: source)
    }
    
}

// MARK: - SourcesViewController (Data Source)  -

extension SourcesViewController {
    
    fileprivate func fetchData() {
        newsWebservice.allSources { [weak self] result in
            switch result {
            case .error(_):
                self?.presentAlertWith(message: "Failed to load sources")
            case .success(let newSources):
                self?.updateDataSource(with: newSources)
            }
        }
    }
    
    fileprivate func updateDataSource(with newData: [Source]) {
        dataSource.update(with: newData)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
}
