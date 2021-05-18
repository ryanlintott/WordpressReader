//
//  RenderedContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, *)
struct RenderedContent: Codable, Hashable, Equatable, ParameterLabels {
    static var labelMaker: RenderedContent = RenderedContent(rendered: "")
    
    var rendered: String
}
