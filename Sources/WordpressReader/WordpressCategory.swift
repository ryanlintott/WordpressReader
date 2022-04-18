//
//  WordpressCategory.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

public struct WordpressCategory: WordpressItem {
    public static var labelMaker: WordpressCategory = WordpressCategory(id: 0, count: 0, description: "", link: "", name: "", slug: "")
    
    public var id: Int
    public var count: Int
    public var description: String
    public var link: String
    public var name: String
    public var slug: String
    
    public static func < (lhs: WordpressCategory, rhs: WordpressCategory) -> Bool {
        lhs.name < rhs.name
    }
    
    public static let urlComponent = "categories"
}
