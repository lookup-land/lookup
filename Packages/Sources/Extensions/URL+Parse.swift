// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import DomainParser
import Foundation
import Network

public enum URLParseError: Error {
    case invalidURL
}

public extension URL {
    static func parseURL(urlString: String) throws -> URL {
        let domainParser = try DomainParser()

        let tld = domainParser.parse(host: urlString)?.publicSuffix

        let initialURL = URL(string: urlString)

        if tld != nil || initialURL?.scheme != nil {
            if let url = initialURL, url.scheme != nil {
                return url
            } else if let url = URL(string: "http://\(urlString)"), url.host != nil {
                return url
            }
        } else {
            let searchTerm = urlString
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "https://www.google.com/search?q=\(searchTerm)") {
                return url
            }
        }

        throw URLParseError.invalidURL
    }
}
