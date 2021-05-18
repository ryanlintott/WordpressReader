//
//  WordpressLogo.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, *)
struct WordpressLogo: Codable, Identifiable, ParameterLabels {
    static var labelMaker: WordpressLogo = WordpressLogo(id: 0, url: "")
    
    var id: Int
    var url: String
}
