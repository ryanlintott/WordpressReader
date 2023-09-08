//
//  WordpressLogo.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// A Wordpress Logo.
public struct WordpressLogo: Codable, Identifiable, Hashable, Equatable, ParameterLabels {
    public static let labelMaker = Self(id: 0, url: "")
    
    /// Unique identifier for the logo
    public var id: Int
    
    /// URL to access the logo image.
    public var url: String
    
    /// Create a logo using properties. Useful for generating sample content.
    public init(id: Int, url: String) {
        self.id = id
        self.url = url
    }
}
