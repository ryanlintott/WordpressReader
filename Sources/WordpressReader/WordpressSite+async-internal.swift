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
    /// - Throws: ``WordpressReaderError`` if there are URL errors, badly formatted query items, or if there is no totalPages value in the header.
    nonisolated func fetchPaginatedUrls<T: WordpressItem>(_ request: WordpressRequest<T>) async throws -> [URL] {
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
    ///   - maxConcurrentTasks: Limits the number of concurrent tasks. Useful when submitting hundreds or thousands of tasks. Default is unclamped, minimum is 2
    /// - Returns: An asynchronous throwing stream of arrays of ``WordpressItem``.
    func itemStream<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL],
        maxConcurrentTasks: Int?
    ) -> AsyncThrowingStream<[T], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await withThrowingTaskGroup(of: [T].self) { group in
                        let maxConcurrentTasks = min(max(2, maxConcurrentTasks ?? .max), urls.count)
                        var taskIndex = 0
                        
                        for _ in 0..<maxConcurrentTasks {
                            let url = urls[taskIndex]
                            group.addTask {
                                try Task.checkCancellation()
                                return try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: .wordpressDate)
                            }
                            taskIndex += 1
                        }
                        
                        /// As each task is completed a new one is added to the group synchronously. This ensures the group only finishes when all urls are processed.
                        for try await batch in group {
                            continuation.yield(batch)
                            
                            if taskIndex < urls.count {
                                let url = urls[taskIndex]
                                group.addTask {
                                    try Task.checkCancellation()
                                    return try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: .wordpressDate)
                                }
                                taskIndex += 1
                            }
                        }
                        
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    /// Returns an array of Wordpress items based on the combined results of every provided URL request.
    /// - Parameters:
    ///   - urlSession: URL session to use. (default is .shared)
    ///   - type: Type of Wordpress item to retrieve.
    ///   - urls: An array of URLs used to retrieve Wordpress items.
    ///   - maxConcurrentTasks: Limits the number of concurrent tasks. Useful when submitting hundreds or thousands of tasks. Default is nil
    /// - Returns: An array of ``WordpressItem`` asynchronously.
    /// - Throws: ``WordpressReaderError`` if there are network errors or if the URLs to not return JSON results that match the provided type.
    nonisolated func fetchItems<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL],
        maxConcurrentTasks: Int?
    ) async throws -> [T] {
        try await itemStream(urlSession: urlSession, type, urls: urls, maxConcurrentTasks: maxConcurrentTasks).reduce(into: [], +=)
    }
}
