//
//  Errors.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

public enum NetworkError: LocalizedError {
    case badURL
    case nonHttpUrl
    case requestFailed
    case unknown(description: String = "An unknown network error occurred.")
    
    static let unknown: Self = .unknown()
    
    public var errorDescription: String? {
        switch self {
        case .badURL:
            return NSLocalizedString("The URL is not valid.", comment: "")
        case .nonHttpUrl:
            return NSLocalizedString("The URL is not a valid HTTP URL", comment: "")
        case .requestFailed:
            return NSLocalizedString("The request failed", comment: "")
        case .unknown(let description):
            return NSLocalizedString(description, comment: "")
        }
    }
}

public enum RequestError: Error {
    case badHeaderName, badURLComponents
}

public enum WordpressError: LocalizedError {
    case APIError(details: String)
    case BadArgument
    case BadURL
    
    public var errorDescription: String? {
        switch self {
        case .APIError(let details):
            return NSLocalizedString("Wordpress API error: \(details)", comment: "")
        case .BadArgument:
            return NSLocalizedString("Bad argument", comment: "")
        case .BadURL:
            return NSLocalizedString("Bad URL", comment: "")
        }
    }
}
