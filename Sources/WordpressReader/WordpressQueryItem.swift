//
//  WordpressQueryItem.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-27.
//

import SwiftUI

/// Enumeration of sorting attributes for Wordpress objects.
public enum WordpressOrderBy: String, Hashable, Equatable, CaseIterable, Sendable {
    /// Order by date posted. (default option)
    case date
    /// Order by id.
    case id
    /// Order by title.
    case title
    /// Order by slug.
    case slug
    /// Order by date modified.
    case modified
}

/// Enumeration of sorting orders for Wordpress objects
public enum WordpressOrder: String, Hashable, Equatable, CaseIterable, Sendable {
    /// Ascending order.
    ///
    /// (Z - A) for string. (oldest - newest) for dates.
    case asc
    
    /// Descending order. (default option)
    ///
    /// (A - Z) for string. (newest - oldest) for dates.
    case desc
}

/// A Wordpress query item.
public enum WordpressQueryItem: Hashable, Comparable, Equatable, Sendable {
    /// An array of fields to return with this query. (An empty array will return all fields)
    ///
    /// When used in a WordpressRequest this parameter is automatically populated using parameter labels of the WordpressItem you're requesting. This shrinks the size of the returned JSON by discarding parameters that cannot be decoded.
    case fields([String])
    /// Limit this query to objects posted after a specific date (default is nil)
    case postedAfter(Date)
    /// Limit this query to objects posted before a specific date (default is nil)
    case postedBefore(Date)
    /// Limit this query to objects modified after a specific date. (default is nil)
    case modifiedAfter(Date)
    /// Limit this query to objects modified before a specific date. (default is nil)
    case modifiedBefore(Date)
    /// Order this query by a specified property (default is .date)
    case orderBy(WordpressOrderBy)
    /// Order this query in a specified direction. (default is .desc)
    case order(WordpressOrder)
    /// Number of objects to include per page (or batch) for large requests. (default is 100)
    case perPage(Int)
    /// Page to return from paginated results. This will be automatically set when iterating through pages in a large request. (default is nil)
    case page(Int)
    /// Available for any other custom query requests not included in this enum.
    case custom(name: String, value: String)
}

public extension WordpressQueryItem {
    /// Name or key for this Wordpress query item as a string. This string will be used in the urlQueryItem.
    var name: String {
        switch self {
        case .fields: return "_fields"
        case .postedAfter: return "after"
        case .postedBefore: return "before"
        case .modifiedAfter: return "modified_after"
        case .modifiedBefore: return "modified_before"
        case .orderBy: return "orderBy"
        case .order: return "order"
        case .perPage: return "per_page"
        case .page: return "page"
        case let .custom(key, _): return key
        }
    }
    
    /// Value as a string. This string will be used in the urlQueryItem.
    var value: String {
        switch self {
        case .fields(let value): return value.joined(separator: ",")
        case .postedAfter(let value),
                .postedBefore(let value),
                .modifiedAfter(let value),
                .modifiedBefore(let value): return Self.dateString(value)
        case .orderBy(let value): return value.rawValue
        case .order(let value): return value.rawValue
        case .perPage(let value),
                .page(let value): return String(value)
        case let .custom(_, value): return value
        }
    }
    
    /// URLQueryItem using the name and value parameters used to build a URL Query.
    var urlQueryItem: URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
    
    
    /// Returns an ISO8601 formatted date string used for date-related query items.
    /// - Parameter date: Date to convert to string.
    /// - Returns: An ISO8601 formatted date string.
    fileprivate static func dateString(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }
    
    /// Default sorting by name.
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
    
    /// Hashed by name so that a set of WordpressQueryItem can only contain one value per name.
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

public extension Collection where Element == WordpressQueryItem {
    /// An array of URL query items created from this collection of Wordpress query items.
    var urlQueryItems: [URLQueryItem] {
        self.map { $0.urlQueryItem }
    }
    
    /// An optional array of fields combining any fields query items in this collection of Wordpress query items.
    ///
    /// Returns nil of no fields value is specified in any element.
    var fields: [String]? {
        let fieldValues: [[String]] = compactMap {
            guard case .fields(let value) = $0 else { return nil }
            return value
        }
        return fieldValues.isEmpty ? nil : fieldValues.reduce(into: []) { $0 += $1 }
    }
    
    /// An array of page query item values collected from this collection of Wordpress query items.
    var pages: [Int] {
        compactMap {
            guard case .page(let value) = $0 else { return nil }
            return value
        }
    }
}

public extension Set where Element == WordpressQueryItem {
    /// An optional page query item value found within this set of Wordpress query items.
    ///
    /// Returns nil if no page value is specified in any element.
    var page: Int? {
        pages.first
    }
}
