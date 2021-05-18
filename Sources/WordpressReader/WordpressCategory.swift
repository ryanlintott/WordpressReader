//
//  WordpressCategory.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
struct WordpressCategory: WordpressItem {
    static var labelMaker: WordpressCategory = WordpressCategory(id: 0, count: 0, description: "", link: "", name: "", slug: "")
    
    var id: Int
    var count: Int
    var description: String
    var link: String
    var name: String
    var slug: String
    
    static func < (lhs: WordpressCategory, rhs: WordpressCategory) -> Bool {
        lhs.name < rhs.name
    }
    
    static let urlComponent = "categories"
}
