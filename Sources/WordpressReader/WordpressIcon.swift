//
//  WordpressIcon.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// Wordpress Icon based on v1 Rest API
public struct WordpressIcon: Codable, Hashable, Equatable, ParameterLabels {
    public static let labelMaker = Self(img: "", ico: "")
    
    /// Image URL for icon
    public var img: String
    /// Appears to be a duplicate of the img property?
    public var ico: String
    
    /// Create a post using properties. Useful for generating sample content.
    public init(img: String, ico: String) {
        self.img = img
        self.ico = ico
    }
}
