//
//  WordpressIcon.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, *)
public struct WordpressIcon: Codable, ParameterLabels {
    public static var labelMaker: WordpressIcon = WordpressIcon(img: "", ico: "")
    
    public var img: String
    public var ico: String
}
