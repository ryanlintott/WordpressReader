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
    /// - Parameter maxConcurrentTasks: Limits the number of concurrent tasks. Useful when submitting hundreds or thousands of tasks. Default is unclamped, minimum is 2
    /// - Returns: An asynchronous throwing stream of arrays of ``WordpressItem``.
    /// - Throws: ``WordpressReaderError``, or DecodingError.
    nonisolated public func stream<T: WordpressItem>(
        _ request: WordpressRequest<T>,
        maxConcurrentTasks: Int? = nil
    ) async throws -> AsyncThrowingStream<[T], Error> {
        let urls = try await fetchPaginatedUrls(request)
        return itemStream(urlSession: request.urlSession, T.self, urls: urls, maxConcurrentTasks: maxConcurrentTasks)
    }
    
    /// Asynchronously returns an array of Wordpress items.
    ///
    /// Use itemStream() if you want to retrieve item batches in an asynchronous stream.
    /// - Parameter request: Wordpress request used to retrieve Wordpress items.
    /// - Parameter maxConcurrentTasks: Limits the number of concurrent tasks. Useful when submitting hundreds or thousands of tasks. Default is unclamped, minimum is 2
    /// - Returns: An array of ``WordpressItem`` asynchronously.
    /// - Throws: ``WordpressReaderError``, or DecodingError.
    nonisolated public func fetch<T: WordpressItem>(
        _ request: WordpressRequest<T>,
        maxConcurrentTasks: Int? = nil
    ) async throws -> [T] {
        let urls = try await fetchPaginatedUrls(request)
        return try await fetchItems(urlSession: request.urlSession, T.self, urls: urls, maxConcurrentTasks: maxConcurrentTasks)
    }
    
    /// Asynchronously returns an array of Wordpress items.
    ///
    /// Use itemStream() if you want to retrieve item batches in an asynchronous stream.
    /// - Parameter type: The type of Wordpress item to retrieve using a default request.
    /// - Parameter maxConcurrentTasks: Limits the number of concurrent tasks. Useful when submitting hundreds or thousands of tasks. Default is unclamped, minimum is 2
    /// - Returns: An array of ``WordpressItem`` asynchronously.
    /// - Throws: ``WordpressReaderError``, or DecodingError.
    nonisolated public func fetch<T: WordpressItem>(
        _ type: T.Type,
        maxConcurrentTasks: Int? = nil
    ) async throws -> [T] {
        try await fetch(T.self.request())
    }
}
