//
//  WordpressSite.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

/// A type that allows API access to a provided site on Wordpress.com
///
/// Does not yet work for sites hosted outside Wordpress.com.
public struct WordpressSite: Codable, Hashable, Sendable {
    /// Site domain excluding http or other prefix.
    ///
    /// Example: `"example.com"`
    public let domain: String
    
    /// Name of the site. (Just used as a label)
    public let name: String
    
    /// URL to access REST API v1.1 for this site
    public let restAPIv1_1Url: URL
    
    /// URL to access REST API v2 for this site
    public let restAPIv2Url: URL
    
    /// Creates a type that allows API access to the provided wordpress.com domain
    /// - Parameters:
    ///   - domain: Wordpress site domain. Example: "example.com"
    ///   - name: Name of the site.
    public init(domain: String, name: String) {
        self.domain = domain
        self.name = name
        restAPIv1_1Url = Self.wordpressDotComRestAPIv1_1Prefix.appendingPathComponent(domain)
        restAPIv2Url = Self.wordpressDotComRestAPIv2Prefix.appendingPathComponent(domain)
    }
    
    /// Prefix for accessing wordpress REST API v1.1
    static let wordpressDotComRestAPIv1_1Prefix = URL(staticString: "https://public-api.wordpress.com/rest/v1.1/sites")
    /// Prefix for accessing wordpress REST API v2
    static let wordpressDotComRestAPIv2Prefix = URL(staticString: "https://public-api.wordpress.com/wp/v2/sites")
    static let totalPagesHeader: String = "X-WP-TotalPages"
    
    /// URL to use when accessing site settings
    public var settingsUrl: URL {
        restAPIv1_1Url
    }
    
    /// URL for the site based on the domain with "https://" added to the beginning.
    public var siteURL: URL {
        URL(string: "https://\(domain)")!
    }

    /// URL that redirects to a post based on its id.
    public func postURL(id: Int) -> URL {
        url(appending: URLQueryItem(name: "p", value: "\(id)"))
    }
    
    /// URL that redirects to a page based on its id.
    public func pageURL(id: Int) -> URL {
        url(appending: URLQueryItem(name: "page_id", value: "\(id)"))
    }

    /// URL that opens a category archive based on its id.
    public func categoryURL(id: Int) -> URL {
        url(appending: URLQueryItem(name: "cat", value: "\(id)"))
    }

    private func url(appending queryItem: URLQueryItem) -> URL {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return siteURL.appending(queryItems: [queryItem])
        } else {
            // Fallback on earlier versions
            var components = URLComponents(url: siteURL, resolvingAgainstBaseURL: false)!
            components.queryItems = [queryItem]
            return components.url!
        }
    }
}
