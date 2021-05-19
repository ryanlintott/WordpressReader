//
//  WordpressContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
public protocol WordpressContent: WordpressItem {
    var date_gmt: Date { get }
    var modified_gmt: Date { get }
    var slug: String { get }
    var link: String { get }
    var title: RenderedContent { get }
    var content: RenderedContent { get }
    var excerpt: RenderedContent { get }
}

@available (iOS 13, macOS 10.15, *)
extension WordpressContent {
    public var slugCleaned: String {
        slug.removingPercentEncoding ?? slug
    }
    
    public var titleCleaned: String {
        title.rendered.removingPercentEncoding ?? title.rendered
    }
    
    public var contentHtml: String {
        content.rendered.removingPercentEncoding ?? content.rendered
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.titleCleaned < rhs.titleCleaned
    }
}
