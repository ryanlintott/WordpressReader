//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-04-27.
//

import Foundation

extension WordpressSite {
    func fetchPaginatedUrls<T: WordpressItem>(_ request: WordpressRequest<T>) async throws -> [URL] {
        let baseUrl = restAPIv2Url.appendingPathComponent(T.self.urlComponent)
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            throw WordpressError.BadURL
        }
        
        let pageRange: ClosedRange<Int>?
        
        if let page = request.queryItems.pages.first {
            pageRange = page...page
        } else {
            urlComponents.queryItems = request.urlQueryItems
            
            guard let url = urlComponents.url else {
                throw RequestError.badURLComponents
            }
            
            let header = try await request.urlSession.fetchHeader(url: url, forHTTPHeaderField: Self.totalPagesHeader)
            
            guard let totalPages = Int(header) else {
                throw WordpressError.APIError(details: "Total pages in header not a valid Integer")
            }
            
            pageRange = request.pageRange(total: totalPages)
        }
        
        // Confirm all page URLs are valid
        return try pageRange?.map { page -> URL in
            var pageUrlComponents = urlComponents
            pageUrlComponents.queryItems = request.urlQueryItems(page)

            guard let url = pageUrlComponents.url else {
                throw WordpressError.BadURL
            }
            return url
        } ?? []
    }
    
    func itemStream<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL]
    ) async -> AsyncThrowingStream<T, Error> {
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
                        batch.forEach { continuation.yield($0) }
                    }
                    continuation.finish()
                }
            }
        }
    }
    
    func fetchItems<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL]
    ) async throws -> [T] {
        try await itemStream(urlSession: urlSession, type, urls: urls).reduce(into: [], { $0.append($1) })
    }
}
