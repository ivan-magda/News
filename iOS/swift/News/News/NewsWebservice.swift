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

import Foundation
import Network

// MARK: NewsWebservice

final class NewsWebservice {
    
    // MARK: Resources
    
    private static let allSources: Resource<[Source]> = Resource(
        url: URL(string: "\(Constants.newsApiBaseUrl.rawValue)sources")!,
        parseJSON: { result in
            guard let json = result as? JSONDictionary,
                let jsonSources = json["sources"] as? [JSONDictionary] else { return nil }
            return jsonSources.flatMap { Source($0) }
    }
    )
    
    // MARK: Properties
    
    private let webservice: CachedWebservice
    
    // MARK: Init
    
    init(_ webservice: CachedWebservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch data
    
    func allSources(_ completion: @escaping (Result<[Source]>) -> ()) {
        webservice.load(NewsWebservice.allSources, update: completion)
    }
    
    func articles(for source: Source, _ completion: @escaping (Result<[Article]>) -> ()) {
        var methodParameters = [
            "source": source.id,
            "apiKey": Constants.newsApiApplicationKey.rawValue
        ]
        if source.sortTypes.count > 0 { methodParameters["sortBy"] = source.sortTypes.first! }
        
        guard let URL = url(withPath: "articles", and: methodParameters) else { return print("URL is nil") }
        let resource: Resource<[Article]> = Resource(
            url: URL,
            parseJSON: { result in
                guard let json = result as? JSONDictionary,
                    let jsonArticles = json["articles"] as? [JSONDictionary] else { return nil }
                return jsonArticles.flatMap { Article($0) }
            }
        )
        webservice.load(resource, update: completion)
    }
    
}

// MARK: - NewsWebservice (Private Helpers) -

extension NewsWebservice {
    fileprivate func url(withPath pathExtension: String? = nil, and parameters: [String: Any]? = nil) -> URL? {
        var components = URLComponents(string: Constants.newsApiBaseUrl.rawValue)!
        components.path += pathExtension ?? ""
        components.queryItems = parameters?.flatMap { URLQueryItem(name: $0, value: "\($1)") }
        
        return components.url
    }
}
