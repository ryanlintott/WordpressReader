//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-04-27.
//

import Foundation

extension WordpressSite {
    @available(*, renamed: "fetchSettings(urlSession:)")
    public func fetchSettings(completion: @escaping (Result<WordpressSettings, Error>) -> Void) {
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
    public func fetchById<T: WordpressItem>(_ type: T.Type, id: Int, completion: @escaping (Result<T, Error>) -> Void) {
        Task {
            do {
                let result = try await fetchById(type, id: id)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    @available(*, renamed: "itemStream(_:)")
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
        batchCompletion: @escaping (Result<[T], Error>) -> Void,
        completion: (() -> Void)? = nil
    ) {
        Task {
            var queryItems: Set<WordpressQueryItem> = []
            if let postedAfter = postedAfter {
                queryItems.update(with: .postedAfter(postedAfter))
            }
            if let postedBefore = postedBefore {
                queryItems.update(with: .postedBefore(postedBefore))
            }
            if let modifiedAfter = modifiedAfter {
                queryItems.update(with: .modifiedAfter(modifiedAfter))
            }
            if let modifiedBefore = modifiedBefore {
                queryItems.update(with: .modifiedBefore(modifiedBefore))
            }
            if let orderBy = orderBy {
                queryItems.update(with: .orderBy(orderBy))
            }
            if let order = order {
                queryItems.update(with: .order(order))
            }
            if let perPage = perPage {
                queryItems.update(with: .perPage(perPage))
            }
            var request = WordpressRequest<T>(queryItems: queryItems)
            request.startPage = startPage
            request.maxPages = maxNumPages
            
            do {
                for try await batch in try await itemStream(request) {
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
    public func fetchItems<T: WordpressItem>(_ type: T.Type, batchCompletion: @escaping (Result<[T], Error>) -> Void, completion: (() -> Void)? = nil) {
        Task {
            let request = WordpressRequest<T>()
            do {
                for try await batch in try await itemStream(request) {
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
    public func fetchAllItems<T: WordpressItem>(_ type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        Task {
            do {
                let result = try await fetchItems(type)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
