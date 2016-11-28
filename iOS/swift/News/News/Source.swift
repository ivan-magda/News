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

struct Source {
    let id: String
    let name: String
    var detail: String?
    let url: String
    let category: String
    let sortTypes: [String]
    let logo: SourceLogo
}

extension Source {
    init?(_ json: [String: Any]) {
        guard let id = json["id"] as? String,
            let name = json["name"] as? String,
            let url = json["url"] as? String,
            let category = json["category"] as? String,
            let sortTypes = json["sortBysAvailable"] as? [String],
            let logosUrls = json["urlsToLogos"] as? [String: Any],
            let small = logosUrls["small"] as? String,
            let medium = logosUrls["medium"] as? String,
            let large = logosUrls["large"] as? String else {
                return nil
        }
        let detail = json["detail"] as? String
        
        self.id = id
        self.name = name
        self.detail = detail
        self.url = url
        self.category = category
        self.sortTypes = sortTypes
        self.logo = SourceLogo(small: small, medium: medium, large: large)
    }
}
