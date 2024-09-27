//
//  RenderedContent.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// Rendered HTML content from the Wordpress API
///
/// Used in ``WordpressContent``
public struct RenderedContent: Codable, Hashable, Equatable, Sendable, ParameterLabels {
    public static let labelMaker = Self(rendered: "")
    
    /// String containing HTML code representing the rendered content on Wordpress.
    public var rendered: String
    
    /// Create rendered content from a string. Useful for generating sample content.
    /// - Parameter rendered: String containing HTML code representing the rendered content on Wordpress.
    public init(rendered: String) {
        self.rendered = rendered
    }
}

extension RenderedContent {
    /// Rendered content removing any percent encoding.
    public var cleaned: String {
        rendered.removingPercentEncoding ?? rendered
    }
}
