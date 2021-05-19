//
//  URLSession-extension.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-07-11.
//

import Foundation
#if os(iOS)
import UIKit
#endif

public enum NetworkError: Error {
    case badURL, nonHttpUrl, requestFailed, unknown
}

public enum RequestError: Error {
    case badHeaderName
}


@available (iOS 13, macOS 10.15, *)
internal extension URLSession {
    static func fetchData(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if error != nil {
                    
                    completion(.failure(NetworkError.requestFailed))
                } else {
                    completion(.failure(NetworkError.unknown))
                }
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    static func fetchData(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        fetchData(url: url, completion: completion)
    }
    
    static func fetchJsonData<T: Decodable>(_ type: T.Type, url: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, completion: @escaping (Result<T, Error>) -> Void) {
        
        fetchData(url: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                decoder.keyDecodingStrategy = keyDecodingStrategy
                
                do {
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func fetchJsonData<T: Decodable>(_ type: T.Type, from urlString: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        fetchJsonData(type, url: url, dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, completion: completion)
    }
    
    static func fetchHeader(url: URL, forHTTPHeaderField header: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.nonHttpUrl))
                return
            }
            
            guard let value = httpResponse.value(forHTTPHeaderField: header) else {
                completion(.failure(RequestError.badHeaderName))
                return
            }
            
            completion(.success(value))
        }.resume()
    }
    
    static func fetchHeader(from urlString: String, forHTTPHeaderField header: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        fetchHeader(url: url, forHTTPHeaderField: header, completion: completion)
    }
    
    static func fetchAllHeaders(url: URL, completion: @escaping (Result<[AnyHashable : Any], Error>) -> Void) {
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.nonHttpUrl))
                return
            }

            completion(.success(httpResponse.allHeaderFields))
        }.resume()
    }
    
    static func fetchAllHeaders(from urlString: String, completion: @escaping (Result<[AnyHashable : Any], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        fetchAllHeaders(url: url, completion: completion)
    }
}
