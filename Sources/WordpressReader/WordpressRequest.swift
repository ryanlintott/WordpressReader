//
//  WordpressRequest.swift
//  
//
//  Created by Ryan Lintott on 2022-04-05.
//

import Foundation

public struct WordpressRequest<T: WordpressItem> {
    public var urlSession: URLSession = .shared
    public var startPage: Int = 1
    public var maxPages: Int? = nil
    public var queryItems: Set<WordpressQueryItem>
    
    public init(queryItems: Set<WordpressQueryItem> = []) {
        self.queryItems = queryItems
        if queryItems.fields == nil {
            // Narrow the search down to only the necessary fields
            self.queryItems.update(with: .fields(T.parameterLabels))
        }
    }
}

public extension WordpressRequest {
    var urlQueryItems: [URLQueryItem] {
        queryItems.urlQueryItems
    }
    
    func urlQueryItems(_ page: Int) -> [URLQueryItem] {
        // If queryItems contains a page property already, it will be used as union will not override
        queryItems.union([.page(page)]).urlQueryItems
    }
    
    func pageRange(total: Int) -> ClosedRange<Int>? {
        guard startPage <= total else { return nil }
        
        let endPage = min(total, startPage + (maxPages ?? total) - 1)
        return startPage...endPage
    }
}
