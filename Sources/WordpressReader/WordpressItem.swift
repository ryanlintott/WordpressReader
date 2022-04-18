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
