//
//  WordpressLogo.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

public struct WordpressLogo: Codable, Identifiable, ParameterLabels {
    public static var labelMaker: WordpressLogo = WordpressLogo(id: 0, url: "")
    
    public var id: Int
    public var url: String
}
