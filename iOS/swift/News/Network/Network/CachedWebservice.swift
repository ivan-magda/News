//
//  Webservice.swift
//  Videos
//
//  Created by Florian on 13/04/16.
//  Copyright © 2016 Chris Eidhof. All rights reserved.
//

import Foundation

public final class CachedWebservice {
    let webservice: Webservice
    let cache = Cache()
    
    public init(_ webservice: Webservice) {
        self.webservice = webservice
    }
    
    public func load<A>(_ resource: Resource<A>, update: @escaping (Result<A>) -> ()) {
        if let result = cache.load(resource) {
            print("cache hit")
            update(.success(result))
        }
        
        let dataResource = Resource<Data>(url: resource.url, parse: { $0 }, method: resource.method)
        webservice.load(dataResource, completion: { result in
            switch result {
            case let .error(error):
                update(.error(error))
            case let .success(data):
                self.cache.save(data, for: resource)
                update(Result(resource.parse(data), or: WebserviceError.other))
            }
        })
    }
}
