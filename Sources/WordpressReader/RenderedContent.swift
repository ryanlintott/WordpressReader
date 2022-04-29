//
//  RenderedContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// Rendered HTML content from the Wordpress API
public struct RenderedContent: Codable, Hashable, Equatable, ParameterLabels {
    public static let labelMaker = Self(rendered: "")
    
    /// String containing HTML code representing the rendered content on Wordpress.
    public var rendered: String
}

extension RenderedContent {
    /// Rendered content removing any percent encoding.
    public var cleaned: String {
        rendered.removingPercentEncoding ?? rendered
    }
}
