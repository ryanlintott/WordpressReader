//
//  WordpressTag.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-29.
//

import Foundation

/// A Wordpress Tag
///
/// This type has a subset of parameters that match the names of those in the Wordpress REST API
/// https://developer.wordpress.org/rest-api/reference/tags/
public struct WordpressTag: WordpressTaxonomy {
    public static let labelMaker = Self(id: 0, link: "", slug: "", count: 0, name: "", description: "")
    
    public var id: Int
    public var link: String
    public var slug: String
    public var count: Int
    public var name: String
    public var description: String
    
    public static let urlComponent = "tags"
}
