//
//  URL-extension.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

// source: https://www.swiftbysundell.com/articles/constructing-urls-in-swift/
internal extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        
        self = url
    }
}
