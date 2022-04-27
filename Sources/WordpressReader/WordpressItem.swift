//
//  WordpressItem.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

public protocol WordpressItem: Codable, Identifiable, Hashable, Comparable, ParameterLabels {
    var id: Int { get }
    var link: String { get }
    var slug: String { get }
    
    static var urlComponent: String { get }
}

public extension WordpressItem {
    /// Creates a wordpress request for this item type.
    /// - Parameter queryItems: Query items to use in this request.
    /// - Returns: A wordpress request for this item type.
    static func request(queryItems: Set<WordpressQueryItem> = []) -> WordpressRequest<Self> {
        WordpressRequest<Self>(queryItems: queryItems)
    }
}
