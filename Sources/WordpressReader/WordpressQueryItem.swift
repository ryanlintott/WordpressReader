//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-03-17.
//

import Foundation

public struct WordpressQueryItem: Hashable, Comparable, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public let name: String
    public let value: String
    
    fileprivate init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    public var urlQueryItem: URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
    
    fileprivate static func date(_ name: String, _ date: Date) -> Self {
        .init(name, ISO8601DateFormatter().string(from: date))
    }
    
    fileprivate static func int(_ name: String, _ int: Int) -> Self {
        .init(name, "\(int)")
    }
}

public extension WordpressQueryItem {
    static func fields(_ value: [String]) -> Self {
        .init("_fields", value.joined(separator: ","))
    }
    
    static func postedAfter(_ value: Date) -> Self {
        .date("after", value)
    }
    
    static func postedBefore(_ value: Date) -> Self {
        .date("before", value)
    }
    
    static func modifiedAfter(_ value: Date) -> Self {
        .date("modified_after", value)
    }
    
    static func modifiedBefore(_ value: Date) -> Self {
        .date("modified_before", value)
    }
    
    static func orderBy(_ value: WordpressOrderBy) -> Self {
        .init("orderBy", value.rawValue)
    }
    
    static func order(_ value: WordpressOrder) -> Self {
        .init("order", value.rawValue)
    }
    
    static func perPage(_ value: Int) -> Self {
        .int("per_page", value)
    }
}

internal extension WordpressQueryItem {
    static func page(_ value: Int) -> Self {
        .int("page", value)
    }
}

public extension Collection where Element == WordpressQueryItem {
    var urlQueryItems: [URLQueryItem] {
        self.map { $0.urlQueryItem }
    }
    
    var fields: [String]? {
        guard let string = self.first(where: { $0.name == WordpressQueryItem.fields([]).name })?.value else {
            return nil
        }
        return string.split(separator: ",").map { String($0) }
    }
    
    var page: Int? {
        guard let string = self.first(where: { $0.name == WordpressQueryItem.page(0).name })?.value else {
            return nil
        }
        return Int(string)
    }
}
