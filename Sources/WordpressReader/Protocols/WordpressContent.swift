//
//  WordpressContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// Wordpress Content
///
/// Used by WordpressPage and WordpressPost
public protocol WordpressContent: WordpressItem {
    /// The date the content was published.
    ///
    /// Label name includes GMT to match Wordpress API but date value is not time-zone specific.
    var date_gmt: Date { get }
    /// The date the content was modified.
    ///
    /// Label name includes GMT to match Wordpress API but date value is not time-zone specific.
    var modified_gmt: Date { get }
    /// The title for the content.
    var title: RenderedContent { get }
    /// The content for the content.
    var content: RenderedContent { get }
    /// The excerpt for the content.
    var excerpt: RenderedContent { get }
    
    static func < (lhs: Self, rhs: Self) -> Bool
}

extension WordpressContent {
    /// Title removing any percent encoding.
    public var titleCleaned: String {
        title.cleaned
    }
    
    /// Content removing any percent encoding.
    public var contentHtml: String {
        content.cleaned
    }
    
    /// Excerpt removing any percent encoding.
    public var excerptCleaned: String {
        excerpt.cleaned
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.titleCleaned < rhs.titleCleaned
    }
}
