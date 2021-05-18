//
//  WordpressItem.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
protocol WordpressItem: Codable, UniqueById, Comparable, ParameterLabels {
    var id: Int { get }
    var link: String { get }
    var slug: String { get }
    
    static var urlComponent: String { get }
}
