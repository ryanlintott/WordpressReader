//
//  WordpressSettings.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, *)
struct WordpressSettings: Codable, Identifiable, ParameterLabels {
    static var labelMaker: WordpressSettings = WordpressSettings(ID: 0, name: "", description: "", URL: "", icon: .labelMaker, logo: .labelMaker)
    
    var ID: Int
    var name: String
    var description: String
    var URL: String
    var icon: WordpressIcon
    var logo: WordpressLogo
    
    var id: Int { self.ID }
}
