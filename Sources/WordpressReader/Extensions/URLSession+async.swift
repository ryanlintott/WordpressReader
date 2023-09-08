//
//  URLSession+async.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

internal extension URLSession {
    typealias ProjectError = WordpressReaderError
    
    @available(iOS, obsoleted: 15.0, message: "This extension is no longer necessary as it's built into URLSession")
    @available(macOS, obsoleted: 12.0, message: "This extension is no longer necessary as it's built into URLSession")
    @available(visionOS, obsoleted: 1.0, message: "This extension is no longer necessary as it's built into URLSession")
    /// Retrieves the contents of a URL and delivers the data asynchronously.
    /// - Parameter url: The URL to retrieve
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a Data instance, and a URLResponse.
    /// - Throws: Error if there is a bad response.
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: ProjectError.unknown())
                }
            }.resume()
        }
    }
    
    /// Retrieves the contents of a URL and delivers the data decoded as a specified type asynchronously.
    /// - Parameters:
    ///   - type: Type to decode from the data.
    ///   - url: URL to retrieve.
    ///   - keyDecodingStrategy: Key strategy for the JSON decoder. Default is .useDefaultKeys.
    ///   - dataDecodingStrategy: Data strategy for the JSON decoder. Default is .deferredToData.
    ///   - dateDecodingStrategy: Date strategy for the JSON decoder. Default is .deferredToDate.
    /// - Returns: An asynchronously-delivered type decoded from the Data contents of the URL.
    /// - Throws: Error if there is a bad response or DecodingError if the type cannot be decoded.
    func fetchJsonData<T: Decodable>(
        _ type: T.Type,
        url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        
        let (data, response) = try await data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw ProjectError.Network.notHTTPURLResponse
        }
        guard response.statusCode == 200 else {
            throw ProjectError.Network.requestFailed(statusCode: response.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        
        return try decoder.decode(T.self, from: data)
    }
    
    /// Retrieves the HTTP URL respose from a URL asynchronously.
    /// - Parameter url: URL to retrieve.
    /// - Returns: An asynchronously-delivered HTTP URL respose.
    /// - Throws: Error if there is a bad response or a non-HTTP URL
    func fetchHTTPURLResponse(url: URL) async throws -> HTTPURLResponse {
        let response: URLResponse
        
        (_, response) = try await self.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProjectError.Network.notHTTPURLResponse
        }

        return httpResponse
    }
    
    /// Retrieves a header from a URL asynchronously.
    /// - Parameters:
    ///   - url: URL to retrieve.
    ///   - header: header to retrieve.
    /// - Returns: An asynchronously-delivered value of the supplied header from the URL.
    /// - Throws: WordpressReaderError if there's a bad response, non-HTTP URL or a bad header name.
    func fetchHeader(url: URL, forHTTPHeaderField header: String) async throws -> String {
        let httpResponse = try await fetchHTTPURLResponse(url: url)
        
        guard let value = httpResponse.value(forHTTPHeaderField: header) else {
            throw ProjectError.Network.badHeaderName(headerName: header)
        }
        
        return value
    }
    
    /// Retrieves all headers from a URL asynchronously.
    /// - Parameter url: URL to retrieve.
    /// - Returns: An asynchronously-delivered dictionary of all header-value pairs from the URL.
    /// - Throws: WordpressReaderError if there is a bad response or a non-HTTP URL
    func fetchAllHeaders(url: URL) async throws -> [AnyHashable: Any] {
        let httpResponse = try await fetchHTTPURLResponse(url: url)
        
        return httpResponse.allHeaderFields
    }
}
