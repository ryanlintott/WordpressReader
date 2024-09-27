//
//  WordpressTaxonomy.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-29.
//

import Foundation

/// A Wordpress Taxonomy used for ``WordpressCategory`` and ``WordpressTag``
public protocol WordpressTaxonomy: WordpressItem {
    /// Number of published posts for the object.
    var count: Int { get }
    /// HTML title for the object.
    var name: String { get }
    /// HTML description of the object.
    var description: String { get }
}

extension WordpressTaxonomy {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
}
