//
//  WordpressSite+async-internal.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-27.
//

import Foundation

extension WordpressSite {
    /// Asynchronously returns an array of paginated URLs based on the supplied request.
    /// - Parameter request: Request used to retrieve paginated URLs
    /// - Returns: An array of paginated URLs based on the supplied request.
    /// - Throws: WordpressReaderError if there are URL errors, badly formatted query items, or if there is no totalPages value in the header.
    func fetchPaginatedUrls<T: WordpressItem>(_ request: WordpressRequest<T>) async throws -> [URL] {
        let baseUrl = restAPIv2Url.appendingPathComponent(T.self.urlComponent)
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            throw WordpressReaderError.URLError.badURL(urlString: baseUrl.absoluteString)
        }
        
        let pageRange: ClosedRange<Int>?
        
        if let page = request.queryItems.pages.first {
            pageRange = page...page
        } else {
            urlComponents.queryItems = request.urlQueryItems
            
            guard let url = urlComponents.url else {
                throw WordpressReaderError.URLError.badURLComponents
            }
            
            let header = try await request.urlSession.fetchHeader(url: url, forHTTPHeaderField: Self.totalPagesHeader)
            
            guard let totalPages = Int(header) else {
                throw WordpressReaderError.API.apiError(details: "Total pages in header not a valid Integer")
            }
            
            pageRange = request.pageRange(total: totalPages)
        }
        
        // Confirm all page URLs are valid
        return try pageRange?.map { page -> URL in
            var pageUrlComponents = urlComponents
            pageUrlComponents.queryItems = request.urlQueryItems(page)

            guard let url = pageUrlComponents.url else {
                throw WordpressReaderError.URLError.badURLComponents
            }
            return url
        } ?? []
    }
    
    /// Returns an asynchronous throwing stream of arrays of Wordpress items.
    ///
    /// Each returned array corresponds to a provided URL.
    /// - Parameters:
    ///   - urlSession: URL session to use. (default is .shared)
    ///   - type: Type of Wordpress item to retrieve.
    ///   - urls: Array of URLs to use when fetching item arrays.
    /// - Returns: An asynchronous throwing stream of arrays of Wordpress items.
    func itemStream<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL]
    ) async -> AsyncThrowingStream<[T], Error> {
        AsyncThrowingStream { continuation in
            Task {
                try await withThrowingTaskGroup(of: [T].self) { group in
                    for url in urls {
                        group.addTask {
                            try Task.checkCancellation()
                            let batch = try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: .wordpressDate)
                            return batch
                        }
                    }
                    
                    for try await batch in group {
                        continuation.yield(batch)
                    }
                    continuation.finish()
                }
            }
        }
    }
    
    /// Returns an array of Wordpress items based on the combined results of every provided URL request.
    /// - Parameters:
    ///   - urlSession: URL session to use. (default is .shared)
    ///   - type: Type of Wordpress item to retrieve.
    ///   - urls: An array of URLs used to retrieve Wordpress items.
    /// - Returns: An array of Wordpress items asynchronously.
    /// - Throws: WordpressReaderError if there are network errors or if the URLs to not return JSON results that match the provided type.
    func fetchItems<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL]
    ) async throws -> [T] {
        try await itemStream(urlSession: urlSession, type, urls: urls).reduce(into: [], { $0 += $1 })
    }
}
