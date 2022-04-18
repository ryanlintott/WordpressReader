//
//  WordpressRequest.swift
//  
//
//  Created by Ryan Lintott on 2022-04-05.
//

import Foundation

public struct WordpressRequest {
    public var urlSession: URLSession = .shared
    public var startPage: Int = 1
    public var perPage: Int = 100
    public var maxPages: Int? = nil
    public var queryItems: [WordpressQueryItem]
    
    public init(queryItems: [WordpressQueryItem] = []) {
        self.queryItems = queryItems
    }
}

public extension WordpressRequest {
    var urlQueryItems: [URLQueryItem] {
        queryItems.urlQueryItems + [
            WordpressQueryItem.perPage(perPage)
        ].urlQueryItems
    }
    
    func urlQueryItems(_ page: Int) -> [URLQueryItem] {
        urlQueryItems + [
            WordpressQueryItem.page(page)
        ].urlQueryItems
    }
    
    func pageRange(total: Int) -> ClosedRange<Int>? {
        guard startPage <= total else { return nil }
        let endPage = min(total, startPage + (maxPages ?? total) - 1)
        return startPage...endPage
    }
    
//    var paginatedUrls: [URL] {
//        get async throws {
//            guard let url = url else {
//                throw WordpressError.BadURL
//            }
//            
//            let header = try await urlSession.fetchHeader(url: url, forHTTPHeaderField: WordpressSite.totalPagesHeader)
//            guard let totalPages = Int(header) else {
//                throw WordpressError.APIError(details: "Total pages in header not a valid Integer")
//            }
//            
//            guard totalPages > 0 else {
//                throw WordpressError.APIError(details: "Total pages less than 1")
//            }
//            
//            guard startPage <= totalPages else { return [] }
//            
//            let endPage = min(totalPages, startPage + (maxPages ?? totalPages) - 1)
//            
//            // Confirm all page URLs are valid
//            return try (startPage...endPage).map { page -> URL in
//                guard var pageUrlComponents = urlComponents else {
//                    throw WordpressError.BadURL
//                }
//                
//                let pageQueries = [
//                    WordpressQueryItem.perPage(perPage),
//                    WordpressQueryItem.page(page)
//                ].map { $0.urlQueryItem }
//                
//                pageUrlComponents
//                    .queryItems?
//                    .append(contentsOf: pageQueries)
//                
//                guard let url = pageUrlComponents.url else {
//                    throw WordpressError.BadURL
//                }
//                return url
//            }
//        }
//    }
//    
//    var gmtDateFormatter: DateFormatter {
//        get throws {
//            guard let timeZone = Calendar.gmt?.timeZone else {
//                throw WordpressError.APIError(details: "GMT timezone not accessible.")
//            }
//            
//            let dateFormatter = DateFormatter()
//            dateFormatter.timeZone = timeZone
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//            return dateFormatter
//        }
//    }
//    
//    func fetchItems() async throws -> [T] {
//        let gmtDateFormatter = try gmtDateFormatter
//        let urls = try await paginatedUrls
//        return try await withThrowingTaskGroup(of: [T].self) { group in
//            for url in urls {
//                group.addTask {
//                    try Task.checkCancellation()
//                    return try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: .formatted(gmtDateFormatter))
//                }
//            }
//            
//            return try await group.reduce(into: []) { $0 += $1 }
//        }
//    }
}
