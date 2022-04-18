//
//  WordpressPost.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

public struct WordpressPost: WordpressContent {
    public static var labelMaker: WordpressPost = WordpressPost(id: 0, date_gmt: Date(), modified_gmt: Date(), slug: "", link: "", title: .labelMaker, content: .labelMaker, excerpt: .labelMaker, categories: [], tags: [])
    
    public var id: Int
//    var date: Date
    public var date_gmt: Date
//    var modified: Date
    public var modified_gmt: Date
    public var slug: String
    public var link: String
    public var title: RenderedContent
    public var content: RenderedContent
    public var excerpt: RenderedContent
    public var categories: [Int]
    public var tags: [Int]
    
    public static let urlComponent = "posts"
}
