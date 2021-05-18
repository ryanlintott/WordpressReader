//
//  WordpressContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
protocol WordpressContent: WordpressItem {
    var date_gmt: Date { get }
    var modified_gmt: Date { get }
    var slug: String { get }
    var link: String { get }
    var title: RenderedContent { get }
    var content: RenderedContent { get }
    var excerpt: RenderedContent { get }
}

//extension WordpressContent {
//    static var gmtDateFormatter: ISO8601DateFormatter {
//        let dateFormatter = ISO8601DateFormatter()
//        return dateFormatter
//    }
//
//    var date: Date {
//        // timeZone defaults to GMT
//        let dateFormatter = ISO8601DateFormatter()
//        dateFormatter.date(from: date_gmt + "Z")
//        Calendar.gmt.date
//    }
//}
