//
//  WordpressSite+closures.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-27.
//

import Foundation

extension WordpressSite {
    @available(*, renamed: "fetchSettings(urlSession:)")
    public func fetchSettings(completion: @Sendable @escaping (Result<WordpressSettings, Error>) -> Void) {
        Task {
            do {
                let result = try await fetchSettings()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    @available(*, renamed: "fetchById(urlSession:_:id:)")
    public func fetchById<T: WordpressItem>(_ type: T.Type, id: Int, completion: @Sendable @escaping (Result<T, Error>) -> Void) {
        Task {
            do {
                let result = try await fetchById(type, id: id)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    @available(*, renamed: "stream(_:)")
    public func fetch<T: WordpressContent>(
        _ request: WordpressRequest<T>,
        batchCompletion: @Sendable @escaping (Result<[T], Error>) -> Void,
        completion: (@Sendable () -> Void)? = nil
    ) {
        Task {
            do {
                for try await batch in try await stream(request) {
                    batchCompletion(.success(batch))
                }
            } catch let error {
                batchCompletion(.failure(error))
            }
            completion?()
        }
    }
    
    @available(*, renamed: "stream(_:)")
    public func fetchContent<T: WordpressContent>(
        _ type: T.Type,
        postedAfter: Date? = nil,
        postedBefore: Date? = nil,
        modifiedAfter: Date? = nil,
        modifiedBefore: Date? = nil,
        orderBy: WordpressOrderBy? = nil,
        order: WordpressOrder? = nil,
        startPage: Int = 1,
        perPage: Int? = nil,
        maxNumPages: Int? = nil,
        batchCompletion: @Sendable @escaping (Result<[T], Error>) -> Void,
        completion: (@Sendable () -> Void)? = nil
    ) {
        Task {
            var queryItems: Set<WordpressQueryItem> = []
            if let postedAfter {
                queryItems.update(with: .postedAfter(postedAfter))
            }
            if let postedBefore {
                queryItems.update(with: .postedBefore(postedBefore))
            }
            if let modifiedAfter {
                queryItems.update(with: .modifiedAfter(modifiedAfter))
            }
            if let modifiedBefore {
                queryItems.update(with: .modifiedBefore(modifiedBefore))
            }
            if let orderBy {
                queryItems.update(with: .orderBy(orderBy))
            }
            if let order {
                queryItems.update(with: .order(order))
            }
            if let perPage {
                queryItems.update(with: .perPage(perPage))
            }
            var request = WordpressRequest<T>(queryItems: queryItems)
            request.startPage = startPage
            request.maxPages = maxNumPages
            
            do {
                for try await batch in try await stream(request) {
                    batchCompletion(.success(batch))
                }
                completion?()
            } catch let error {
                batchCompletion(.failure(error))
                completion?()
            }
        }
    }
    
    @available(*, renamed: "itemStream(_:)")
    public func fetchItems<T: WordpressItem>(
        _ type: T.Type,
        batchCompletion: @Sendable @escaping (Result<[T], Error>) -> Void,
        completion: (@Sendable () -> Void)? = nil
    ) {
        Task {
            let request = WordpressRequest<T>()
            do {
                for try await batch in try await stream(request) {
                    batchCompletion(.success(batch))
                }
                completion?()
            } catch let error {
                batchCompletion(.failure(error))
                completion?()
            }
        }
    }
    
    @available(*, renamed: "fetchItems(_:)")
    public func fetchAllItems<T: WordpressItem>(
        _ type: T.Type,
        completion: @Sendable @escaping (Result<[T], Error>) -> Void
    ) {
        Task {
            do {
                let result = try await fetch(type)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
