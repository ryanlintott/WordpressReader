//
//  WordpressSite+async-public.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

extension WordpressSite {
    /// Returns Wordpress settings for this site.
    /// - Parameter urlSession: URL session to use for this request.
    /// - Returns: ``WordpressSettings``.
    /// - Throws: WordpressReaderError if there is a bad response or DecodingError if the type cannot be decoded.
    nonisolated public func fetchSettings(urlSession: URLSession = .shared) async throws -> WordpressSettings {
        try await urlSession.fetchJsonData(
            WordpressSettings.self,
            url: settingsUrl,
            dateDecodingStrategy: .wordpressDate
        )
    }
    
    /// Returns a Wordpress item matching a supplied unique identifier.
    /// - Parameters:
    ///   - urlSession: URL session to use for this request.
    ///   - type: Type of Wordpress Item.
    ///   - id: Unique identifier for ``WordpressItem``.
    /// - Returns: A ``WordpressItem`` matching a supplied unique identifier.
    /// - Throws: ``WordpressReaderError`` if there is a bad response or DecodingError if the type cannot be decoded.
    nonisolated public func fetchById<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        id: Int
    ) async throws -> T {
        let url = restAPIv2Url
            .appendingPathComponent(type.urlComponent)
            .appendingPathComponent("\(id)")
        
        return try await urlSession.fetchJsonData(T.self, url: url)
    }
    
    /// Asynchronously returns an asynchronous throwing stream of arrays of Wordpress items.
    /// 
    /// The throwing asynchronous stream returns batches that correspond to pages from the Wordpress API and will finish when all batches have completed. They may throw a WordpressReaderError if there are URL errors, badly formatted query items, or a bad response or a DecodingError if the JSON doesn't match the Wordpress item.
    /// - Parameter request: Wordpress request used to retrieve Wordpress items.
    /// - Parameter maxConcurrentTasks: The maximum number of concurrent tasks. Default is 8, minimum is 1.
    /// - Returns: An asynchronous throwing stream of arrays of ``WordpressItem``.
    /// - Throws: ``WordpressReaderError``, or DecodingError.
    nonisolated public func stream<T: WordpressItem>(
        _ request: WordpressRequest<T>,
        maxConcurrentTasks: Int? = nil
    ) async throws -> AsyncThrowingStream<[T], Error> {
        let pagination = try await fetchPagination(request)
        let urls = pagination.remainingUrls

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try Task.checkCancellation()
                    if let firstBatch = pagination.firstBatch {
                        continuation.yield(firstBatch)
                    }

                    try await withThrowingTaskGroup(of: [T].self) { group in
                        let maxConcurrentTasks = min(max(1, maxConcurrentTasks ?? 8), urls.count)
                        var taskIndex = 0

                        for _ in 0..<maxConcurrentTasks {
                            let url = urls[taskIndex]
                            group.addTask {
                                try Task.checkCancellation()
                                return try await request.urlSession.fetchJsonData(
                                    [T].self,
                                    url: url,
                                    dateDecodingStrategy: .wordpressDate
                                )
                            }
                            taskIndex += 1
                        }

                        // Add a new task whenever one finishes so the group never exceeds the limit.
                        for try await batch in group {
                            continuation.yield(batch)

                            if taskIndex < urls.count {
                                let url = urls[taskIndex]
                                group.addTask {
                                    try Task.checkCancellation()
                                    return try await request.urlSession.fetchJsonData(
                                        [T].self,
                                        url: url,
                                        dateDecodingStrategy: .wordpressDate
                                    )
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
    
    /// Asynchronously returns an array of Wordpress items.
    ///
    /// Use ``stream(_:maxConcurrentTasks:)`` to retrieve item batches as they complete.
    /// - Parameter request: Wordpress request used to retrieve Wordpress items.
    /// - Parameter maxConcurrentTasks: The maximum number of concurrent tasks. Default is 8, minimum is 1.
    /// - Returns: An array of ``WordpressItem`` asynchronously.
    /// - Throws: ``WordpressReaderError``, or DecodingError.
    nonisolated public func fetch<T: WordpressItem>(
        _ request: WordpressRequest<T>,
        maxConcurrentTasks: Int? = nil
    ) async throws -> [T] {
        try await stream(request, maxConcurrentTasks: maxConcurrentTasks).reduce(into: [], +=)
    }
    
    /// Asynchronously returns an array of Wordpress items.
    ///
    /// Use ``stream(_:maxConcurrentTasks:)`` to retrieve item batches as they complete.
    /// - Parameter type: The type of Wordpress item to retrieve using a default request.
    /// - Parameter maxConcurrentTasks: The maximum number of concurrent tasks. Default is 8, minimum is 1.
    /// - Returns: An array of ``WordpressItem`` asynchronously.
    /// - Throws: ``WordpressReaderError``, or DecodingError.
    nonisolated public func fetch<T: WordpressItem>(
        _ type: T.Type,
        maxConcurrentTasks: Int? = nil
    ) async throws -> [T] {
        try await fetch(T.self.request(), maxConcurrentTasks: maxConcurrentTasks)
    }
}
