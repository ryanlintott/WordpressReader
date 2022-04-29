//
//  URL-extension.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

internal extension URL {
    /// Creates a URL instance from the provided static string.
    /// - Parameter string: A static string of the URL
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        
        self = url
    }
}
