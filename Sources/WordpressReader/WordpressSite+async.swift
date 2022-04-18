//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

// Not used yet
public extension WordpressSite {
    func fetchSettings(urlSession: URLSession = .shared) async throws -> WordpressSettings {
        try await urlSession.fetchJsonData(
            WordpressSettings.self,
            url: settingsUrl,
            dateDecodingStrategy: gmtDateDecodingStrategy
        )
    }
    
    func fetchById<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        id: Int
    ) async throws -> T {
        let url = restAPIv2Url
            .appendingPathComponent(type.urlComponent)
            .appendingPathComponent("\(id)")
        
        return try await urlSession.fetchJsonData(T.self, url: url)
    }
    
    internal func restAPIv2UrlComponents<T: WordpressItem>(_ type: T.Type) -> URLComponents? {
        let baseUrl = restAPIv2Url.appendingPathComponent(type.urlComponent)
        return URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    }
    
    func fetchPaginatedUrls<T: WordpressItem>(_ type: T.Type, request: WordpressRequest<T>) async throws -> [URL] {
        guard var urlComponents = restAPIv2UrlComponents(type) else {
            throw WordpressError.BadURL
        }
        
        let pageRange: ClosedRange<Int>?
        
        if let page = request.queryItems.page {
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
    
    func items<T: WordpressItem>(
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
//                            print("\(Date()) Task Starting")
                            let batch = try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: gmtDateDecodingStrategy)
//                            print("\(Date()) Task: \(url.absoluteString)")
                            return batch
                        }
                    }
                    
                    for try await batch in group {
                        batch.forEach { continuation.yield($0) }
//                        continuation.yield(batch)
                    }
                    continuation.finish()
                }
            }
        }
    }
    
    func items<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        urls: [URL]
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: [T].self) { group in
            for url in urls {
                group.addTask {
                    // Don't need to check cancellation as urlSession will do that
//                    try Task.checkCancellation()
//                    print("\(Date()) Task Starting")
                    let batch = try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: gmtDateDecodingStrategy)
//                    print("\(Date()) Task: \(url.absoluteString)")
                    return batch
                }
            }
            
            return try await group.reduce(into: []) { $0.append(contentsOf: $1) }
        }
    }
    
    func items<T: WordpressItem>(
        _ type: T.Type,
        request: WordpressRequest<T>? = nil
    ) async throws -> [T] {
        let request = request ?? type.request()
        let urls = try await fetchPaginatedUrls(type, request: request)
        return try await items(urlSession: request.urlSession, type, urls: urls)
    }
    
    func stream<T: WordpressItem>(
        _ type: T.Type,
        request: WordpressRequest<T>? = nil
    ) async throws -> AsyncThrowingStream<T, Error> {
        let request = request ?? type.request()
        let urls = try await fetchPaginatedUrls(type, request: request)
        return await items(type, urls: urls)
    }
    
    func postStream(_ request: WordpressRequest<WordpressPost>? = nil) async throws -> AsyncThrowingStream<WordpressPost, Error> {
        try await stream(WordpressPost.self, request: request)
    }
    
    func pageStream(_ request: WordpressRequest<WordpressPage>? = nil) async throws -> AsyncThrowingStream<WordpressPage, Error> {
        try await stream(WordpressPage.self, request: request)
    }
    
    func categoryStream(_ request: WordpressRequest<WordpressCategory>? = nil) async throws -> AsyncThrowingStream<WordpressCategory, Error> {
        try await stream(WordpressCategory.self, request: request)
    }
}
