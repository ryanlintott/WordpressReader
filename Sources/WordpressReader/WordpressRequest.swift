//
//  WordpressRequest.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-05.
//

import Foundation

/// A Wordpress API request for a specified WordpressItem
public struct WordpressRequest<T: WordpressItem>: Hashable, Equatable, Sendable {
    /// URL session to use for the request (default is .shared)
    public var urlSession: URLSession = .shared
    /// Start page to use when returning paginated content. (default is 1)
    public var startPage: Int = 1
    /// Maximum number of pages to return. (default is nil)
    ///
    /// The default number of items per page is 100 but it can also be specified in query items.
    public var maxPages: Int? = nil
    
    /// A set of query items that can be used to narrow this request.
    ///
    /// A field query item inside an assigned set will be ignored and replaced with fields based on the parameter labels for the supplied Wordpress item type.
    public var queryItems: Set<WordpressQueryItem> {
        didSet {
            queryItems.update(with: .fields(T.parameterLabels))
        }
    }
    
    /// Creates a Wordpress request.
    ///
    /// A custom URL session, start page and max pages can all be set after creation. A fields query item will be ignored and replaced with fields based on the parameter labels for the supplied Wordpress item type.
    /// - Parameter queryItems: Query items used in this request. (default is an empty array)
    public init(queryItems: Set<WordpressQueryItem> = []) {
        self.queryItems = queryItems
    }
}

public extension WordpressRequest {
    /// An array of URL query items created from the Wordpress query items.
    var urlQueryItems: [URLQueryItem] {
        queryItems.urlQueryItems
    }
    
    /// Returns an array of URL query items created from the Wordpress query items, adding a specified page if one is not already included in the query.
    /// - Parameter page: Page to add to the query if one isn't already included.
    /// - Returns: An array of URL query items created from the Wordpress query items, adding a specified page if one is not already included in the query.
    func urlQueryItems(_ page: Int) -> [URLQueryItem] {
        // If queryItems contains a page property already, it will be used as union will not override
        queryItems.union([.page(page)]).urlQueryItems
    }
    
    /// Returns the page rage for this request using the start page, max pages and total pages.
    /// - Parameter total: Total pages for this request ignoring start page and max pages. This value can be found in the header when making an initial request.
    /// - Returns: Page range from start page (default 1) to the end page (determined by max pages or the total number of pages)
    func pageRange(total: Int) -> ClosedRange<Int>? {
        guard startPage <= total else { return nil }
        
        let endPage = min(total, startPage + (maxPages ?? total) - 1)
        return startPage...endPage
    }
}

public extension WordpressRequest<WordpressPost> {
    /// Creates a Wordpress request for Posts.
    ///
    /// A custom URL session, start page and max pages can all be set after creation. A fields query item will be ignored and replaced with fields based on the parameter labels for ``WordpressPost``.
    /// - Parameter queryItems: Query items used in this request. (default is an empty array)
    /// - Returns: A Wordpress request for Posts.
    static func posts(_ queryItems: Set<WordpressQueryItem> = []) -> Self {
        .init(queryItems: queryItems)
    }
}

public extension WordpressRequest<WordpressPage> {
    /// Creates a Wordpress request for Pages.
    ///
    /// A custom URL session, start page and max pages can all be set after creation. A fields query item will be ignored and replaced with fields based on the parameter labels for ``WordpressPage``.
    /// - Parameter queryItems: Query items used in this request. (default is an empty array)
    /// - Returns: A Wordpress request for Pages.
    static func pages(_ queryItems: Set<WordpressQueryItem> = []) -> Self {
        .init(queryItems: queryItems)
    }
}

public extension WordpressRequest<WordpressCategory> {
    /// Creates a Wordpress request for Categories.
    ///
    /// A custom URL session, start page and max pages can all be set after creation. A fields query item will be ignored and replaced with fields based on the parameter labels for ``WordpressCategory``.
    /// - Parameter queryItems: Query items used in this request. (default is an empty array)
    /// - Returns: A Wordpress request for Categories.
    static func categories(_ queryItems: Set<WordpressQueryItem> = []) -> Self {
        .init(queryItems: queryItems)
    }
}

public extension WordpressRequest<WordpressTag> {
    /// Creates a Wordpress request for Tags.
    ///
    /// A custom URL session, start page and max pages can all be set after creation. A fields query item will be ignored and replaced with fields based on the parameter labels for ``WordpressTag``.
    /// - Parameter queryItems: Query items used in this request. (default is an empty array)
    /// - Returns: A Wordpress request for Tags.
    static func tags(_ queryItems: Set<WordpressQueryItem> = []) -> Self {
        .init(queryItems: queryItems)
    }
}
