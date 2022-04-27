//
//  WordpressQueryItem.swift
//  
//
//  Created by Ryan Lintott on 2022-04-27.
//

import SwiftUI

public enum WordpressOrderBy: String {
    /// (Default) Date an item was posted
    case date
    
    /// Date an item was modified
    case modified
}

public enum WordpressOrder: String {
    /// Ascending order. Loads oldest dates first
    case asc
    
    /// (Default) Descending order. Loads newest dates first
    case desc
}

public enum WordpressQueryItem: Hashable, Comparable, Equatable {
    case fields([String])
    case postedAfter(Date)
    case postedBefore(Date)
    case modifiedAfter(Date)
    case modifiedBefore(Date)
    case orderBy(WordpressOrderBy)
    case order(WordpressOrder)
    case perPage(Int)
    case page(Int)
    case custom(name: String, value: String)
}

public extension WordpressQueryItem {
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
    
    var urlQueryItem: URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
    
    fileprivate static func dateString(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

public extension Collection where Element == WordpressQueryItem {
    var urlQueryItems: [URLQueryItem] {
        self.map { $0.urlQueryItem }
    }
    
    var fields: [String]? {
        let fieldValues: [[String]] = compactMap {
            guard case .fields(let value) = $0 else { return nil }
            return value
        }
        return fieldValues.isEmpty ? nil : fieldValues.reduce(into: []) { $0 += $1 }
    }
    
    var pages: [Int] {
        compactMap {
            guard case .page(let value) = $0 else { return nil }
            return value
        }
    }
}

public extension Set where Element == WordpressQueryItem {
    var page: Int? {
        pages.first
    }
}
