//
//  Errors.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

/// A network error.
public enum NetworkError: LocalizedError {
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
    /// Unknown network error with supplied description.
    case unknown(description: String = "An unknown network error occurred.")
    
    /// Unknown network error without a reason.
    static let unknown: Self = .unknown()
    
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
        case .unknown(let description):
            return NSLocalizedString(description, comment: "")
        }
    }
}

/// A Wordpress Rest API error
public enum WordpressError: LocalizedError {
    case apiError(details: String)
    case badArgument
    
    public var errorDescription: String? {
        switch self {
        case .apiError(let details):
            return NSLocalizedString("Wordpress API error: \(details)", comment: "")
        case .badArgument:
            return NSLocalizedString("Wordpress Error: bad argument", comment: "")
        }
    }
}
