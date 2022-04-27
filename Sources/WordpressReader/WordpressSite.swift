//
//  WordpressSite.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

/// A type that allows API access to a provided site on Wordpress.com
///
/// Does not yet work for sites hosted outside Wordpress.com.
public struct WordpressSite {
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
}
