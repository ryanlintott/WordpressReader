//
//  WordpressIcon.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, *)
struct WordpressIcon: Codable, ParameterLabels {
    static var labelMaker: WordpressIcon = WordpressIcon(img: "", ico: "")
    
    var img: String
    var ico: String
}
