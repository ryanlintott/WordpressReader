//
//  WordpressPost.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// A Wordpress Post
///
/// This type has a subset of parameters that match the names of those in the Wordpress REST API
/// https://developer.wordpress.org/rest-api/reference/posts/
public struct WordpressPost: WordpressContent {
    public static let labelMaker: WordpressPost = WordpressPost(id: 0, link: "", slug: "", date_gmt: Date(), modified_gmt: Date(), title: .labelMaker, content: .labelMaker, excerpt: .labelMaker, categories: [], tags: [])
    
    public var id: Int
    public var link: String
    public var slug: String
    
    public var date_gmt: Date
    public var modified_gmt: Date
    public var title: RenderedContent
    public var content: RenderedContent
    public var excerpt: RenderedContent
    
    /// An array of unique identifiers for WordpressCategory objects
    public var categories: [Int]
    
    /// An array of unique identifiers for WordpressTag objects
    public var tags: [Int]
    
    public static let urlComponent = "posts"
}
