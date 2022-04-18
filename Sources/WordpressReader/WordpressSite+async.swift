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
    
    func fetchPaginatedUrls<T: WordpressItem>(_ type: T.Type, request: WordpressRequest) async throws -> [URL] {
        guard var urlComponents = restAPIv2UrlComponents(type) else {
            throw WordpressError.BadURL
        }
        urlComponents.queryItems = request.urlQueryItems
        
        guard let url = urlComponents.url else {
            throw RequestError.badURLComponents
        }
        
        let header = try await request.urlSession.fetchHeader(url: url, forHTTPHeaderField: Self.totalPagesHeader)
        
        guard let totalPages = Int(header) else {
            throw WordpressError.APIError(details: "Total pages in header not a valid Integer")
        }
        
        guard let pageRange = request.pageRange(total: totalPages) else {
            return []
        }
        
        // Confirm all page URLs are valid
        return try pageRange.map { page -> URL in
            var pageUrlComponents = urlComponents
            pageUrlComponents.queryItems = request.urlQueryItems(page)

            guard let url = pageUrlComponents.url else {
                throw WordpressError.BadURL
            }
            return url
        }
    }
    
    func items<T: WordpressItem>(
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
//                            print("\(Date()) Task Starting")
                            let batch = try await urlSession.fetchJsonData([T].self, url: url, dateDecodingStrategy: gmtDateDecodingStrategy)
//                            print("\(Date()) Task: \(url.absoluteString)")
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
        request: WordpressRequest = .init()
    ) async throws -> [T] {
        let urls = try await fetchPaginatedUrls(type, request: request)
        return try await items(urlSession: request.urlSession, type, urls: urls)
    }
    
    func stream<T: WordpressItem>(
        _ type: T.Type,
        request: WordpressRequest = .init()
    ) async throws -> AsyncThrowingStream<[T], Error> {
        let urls = try await fetchPaginatedUrls(type, request: request)
        return try await items(type, urls: urls)
    }
    
    func postStream(_ request: WordpressRequest = .init()) async throws -> AsyncThrowingStream<[WordpressPost], Error> {
        try await stream(WordpressPost.self, request: request)
    }
    
    func pageStream(_ request: WordpressRequest = .init()) async throws -> AsyncThrowingStream<[WordpressPage], Error> {
        try await stream(WordpressPage.self, request: request)
    }
    
    func categoryStream(_ request: WordpressRequest = .init()) async throws -> AsyncThrowingStream<[WordpressCategory], Error> {
        try await stream(WordpressCategory.self, request: request)
    }
}
