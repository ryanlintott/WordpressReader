//
//  WordpressItem.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
public protocol WordpressItem: Codable, Identifiable, Hashable, Comparable, ParameterLabels {
    var id: Int { get }
    var link: String { get }
    var slug: String { get }
    
    static var urlComponent: String { get }
    
    func hash(into hasher: inout Hasher)
    
    static func == (lhs: Self, rhs: Self) -> Bool
}

@available (iOS 13, macOS 10.15, *)
extension WordpressItem {
    public func hash(into hasher: inout Hasher) {
      hasher.combine(String(describing: Self.self))
      hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id
    }
}
