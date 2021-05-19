//
//  RenderedContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

@available (iOS 13, *)
public struct RenderedContent: Codable, Hashable, Equatable, ParameterLabels {
    public static var labelMaker: RenderedContent = RenderedContent(rendered: "")
    
    public var rendered: String
}
