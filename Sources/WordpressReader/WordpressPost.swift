//
//  WordpressPost.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
struct WordpressPost: WordpressContent {
    static var labelMaker: WordpressPost = WordpressPost(id: 0, date_gmt: Date(), modified_gmt: Date(), slug: "", link: "", title: .labelMaker, content: .labelMaker, excerpt: .labelMaker, categories: [], tags: [])
    
    var id: Int
//    var date: Date
    var date_gmt: Date
//    var modified: Date
    var modified_gmt: Date
    var slug: String
    var link: String
    var title: RenderedContent
    var content: RenderedContent
    var excerpt: RenderedContent
    var categories: [Int]
    var tags: [Int]
    
    var slugCleaned: String {
        slug.removingPercentEncoding ?? slug
    }
    var titleCleaned: String {
        title.rendered.removingPercentEncoding ?? title.rendered
    }
    var contentHtml: String {
        content.rendered.removingPercentEncoding ?? content.rendered
    }
    
    static func < (lhs: WordpressPost, rhs: WordpressPost) -> Bool {
        lhs.titleCleaned < rhs.titleCleaned
    }
    
    static let urlComponent = "posts"
}
