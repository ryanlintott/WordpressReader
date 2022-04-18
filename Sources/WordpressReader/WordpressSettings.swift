//
//  WordpressSettings.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

public struct WordpressSettings: Codable, Identifiable, ParameterLabels {
    public static var labelMaker: WordpressSettings = WordpressSettings(ID: 0, name: "", description: "", URL: "", icon: .labelMaker, logo: .labelMaker)
    
    public var ID: Int
    public var name: String
    public var description: String
    public var URL: String
    public var icon: WordpressIcon
    public var logo: WordpressLogo
    
    public var id: Int { self.ID }
}
