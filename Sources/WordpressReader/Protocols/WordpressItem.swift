//
//  WordpressItem.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// A Wordpress item that is identifiable with a link and a slug.
///
/// Used by WordpressContent and WordpressCategory
public protocol WordpressItem: Codable, Identifiable, Hashable, Comparable, Sendable, CustomDebugStringConvertible, ParameterLabels {
    /// Unique Wordpress identifier for the object.
    var id: Int { get }
    /// URL to the object.
    var link: String { get }
    /// An alphanumeric identifier for the object unique to its type.
    var slug: String { get }
    
    /// URL component used to access objects of this type.
    static var urlComponent: String { get }
}

public extension WordpressItem {
    /// Creates a wordpress request for this item type.
    /// - Parameter queryItems: Query items to use in this request.
    /// - Returns: A wordpress request for this item type.
    static func request(_ queryItems: Set<WordpressQueryItem> = []) -> WordpressRequest<Self> {
        WordpressRequest<Self>(queryItems: queryItems)
    }
    
    /// Slug removing any percent encoding.
    var slugCleaned: String {
        slug.removingPercentEncoding ?? slug
    }

    var debugDescription: String {
        "slug: \(slug), id: \(id), link: \(link)"
    }
}
