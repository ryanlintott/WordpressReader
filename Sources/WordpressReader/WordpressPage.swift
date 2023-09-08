//
//  WordpressPage.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// A Wordpress Page
///
/// This type has a subset of parameters that match the names of those in the Wordpress REST API
/// https://developer.wordpress.org/rest-api/reference/pages/
public struct WordpressPage: WordpressContent {
    public static let labelMaker: WordpressPage = WordpressPage(id: 0, link: "", slug: "", date_gmt: Date(), modified_gmt: Date(), title: .labelMaker, content: .labelMaker, excerpt: .labelMaker)
    
    public var id: Int
    public var link: String
    public var slug: String
    
    public var date_gmt: Date
    public var modified_gmt: Date
    public var title: RenderedContent
    public var content: RenderedContent
    public var excerpt: RenderedContent
    
    /// Create a page using properties. Useful for generating sample content.
    public init(
        id: Int,
        link: String,
        slug: String,
        date_gmt: Date,
        modified_gmt: Date,
        title: RenderedContent,
        content: RenderedContent,
        excerpt: RenderedContent
    ) {
        self.id = id
        self.link = link
        self.slug = slug
        self.date_gmt = date_gmt
        self.modified_gmt = modified_gmt
        self.title = title
        self.content = content
        self.excerpt = excerpt
    }
    
    public static let urlComponent = "pages"
}
