//
//  Errors.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

/// A Wordpress Rest API error
public enum WordpressReaderError: LocalizedError {
    /// An invalid URL.
    case badURL
    /// An invalid HTTP URL.
    case nonHttpURL
    /// An invalid header name.
    case badHeaderName
    /// Invalid URL components
    case badURLComponents
    /// The network request faild.
    case requestFailed
    /// Error with Wordpress API
    case apiError(details: String)
    /// Bad argument supplied to Wordpress API
    case badArgument
    /// Unknown error with supplied description.
    case unknown(description: String = "An unknown Wordpress error occurred.")
    
    public var errorDescription: String? {
        switch self {
        case .badURL:
            return NSLocalizedString("The URL is not a valid URL", comment: "")
        case .nonHttpURL:
            return NSLocalizedString("The URL is not a valid HTTP URL", comment: "")
        case .badHeaderName:
            return NSLocalizedString("The URL header is invalid", comment: "")
        case .badURLComponents:
            return NSLocalizedString("The URL components are invalid", comment: "")
        case .requestFailed:
            return NSLocalizedString("The request failed", comment: "")
        case .apiError(let details):
            return NSLocalizedString("Wordpress API error: \(details)", comment: "")
        case .badArgument:
            return NSLocalizedString("Wordpress Error: bad argument", comment: "")
        case .unknown(let description):
            return NSLocalizedString(description, comment: "")
        }
    }
}
