//
//  WordpressPage.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
public struct WordpressPage: WordpressContent {
    public static var labelMaker: WordpressPage = WordpressPage(id: 0, date_gmt: Date(), modified_gmt: Date(), slug: "", link: "", title: .labelMaker, content: .labelMaker, excerpt: .labelMaker)
    
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
    
    public static let urlComponent = "pages"
}
