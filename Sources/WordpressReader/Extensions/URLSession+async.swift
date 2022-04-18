//
//  URLSession+async.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

internal extension URLSession {
    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary as it's built into the API")
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: NetworkError.unknown)
                }
            }.resume()
        }
    }
    
    func fetchJsonData<T: Decodable>(_ type: T.Type, url: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) async throws -> T {
        
        let (data, response) = try await data(from: url)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        return try decoder.decode(T.self, from: data)
    }
    
    func fetchHTTPURLResponse(url: URL) async throws -> HTTPURLResponse {
        let response: URLResponse
        
        (_, response) = try await self.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.nonHttpUrl
        }

        return httpResponse
    }
    
    func fetchHeader(url: URL, forHTTPHeaderField header: String) async throws -> String {
        let httpResponse = try await fetchHTTPURLResponse(url: url)
        
        guard let value = httpResponse.value(forHTTPHeaderField: header) else {
            throw RequestError.badHeaderName
        }
        
        return value
    }
    
    func fetchAllHeaders(url: URL) async throws -> [AnyHashable: Any] {
        let httpResponse = try await fetchHTTPURLResponse(url: url)
        
        return httpResponse.allHeaderFields
    }
}
