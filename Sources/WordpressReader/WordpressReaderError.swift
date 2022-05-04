//
//  WordpressReaderError.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

/// A Wordpress Rest API error
public enum WordpressReaderError: LocalizedError {
    /// A URL error
    public enum URLError: LocalizedError {
        /// An invalid URL.
        case badURL(urlString: String)
        /// An invalid HTTP URL.
        case nonHttpURL(URL)
        /// Invalid URL components
        case badURLComponents
        
        public var errorDescription: String? {
            switch self {
            case .badURL(let urlString):
                return NSLocalizedString("Not a valid URL: \(urlString)", comment: "")
            case .nonHttpURL(let url):
                return NSLocalizedString("Not a valid HTTP URL: \(url.absoluteString)", comment: "")
            case .badURLComponents:
                return NSLocalizedString("The URL components are invalid", comment: "")
            }
        }
    }
    
    /// A network error.
    public enum Network: LocalizedError {
        /// An invalid header name.
        case badHeaderName(headerName: String)
        /// The response was not an HTTP URL response.
        case notHTTPURLResponse
        /// Request failed with an optional status code
        case requestFailed(statusCode: Int? = nil)
        /// Unknown network error with supplied description.
        case unknown(description: String = "An unknown network error occurred.")
        
        /// Unknown network error without a reason.
        public static let unknown: Self = .unknown()
        
        public var errorDescription: String? {
            switch self {
            case .badHeaderName(let headerName):
                return NSLocalizedString("URL header is invalid: \(headerName)", comment: "")
            case .notHTTPURLResponse:
                return NSLocalizedString("The response was not an HTTP URL response.", comment: "")
            case let .requestFailed(.some(statusCode)):
                return NSLocalizedString("The request failed. Error code: \(statusCode)", comment: "")
            case .requestFailed(.none):
                return NSLocalizedString("The request failed.", comment: "")
            case .unknown(let description):
                return NSLocalizedString(description, comment: "")
            }
        }
    }
    
    /// Data-related error
    public enum Data: LocalizedError {
        case notDecodableAsType(type: String)
        
        public var errorDescription: String? {
            switch self {
            case .notDecodableAsType(let type):
                return NSLocalizedString("Data does not match type: \(type)", comment: "")
            }
        }
    }
    
    /// Data-related error
    public enum API: LocalizedError {
        /// Bad argument supplied to Wordpress API
        case badArgument
        /// Error with Wordpress API
        case apiError(details: String)
        
        public var errorDescription: String? {
            switch self {
            case .badArgument:
                return NSLocalizedString("Wordpress Error: bad argument", comment: "")
            case .apiError(let details):
                return NSLocalizedString("Wordpress API error: \(details)", comment: "")
            }
        }
    }
    
    /// Unknown error with supplied description.
    case unknown(description: String = "An unknown Wordpress error occurred.")
    
    public var errorDescription: String? {
        switch self {
        case .unknown(let description):
            return NSLocalizedString(description, comment: "")
        }
    }
}
