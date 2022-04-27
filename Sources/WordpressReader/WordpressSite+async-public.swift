//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-03-11.
//

import Foundation

extension WordpressSite {
    public func fetchSettings(urlSession: URLSession = .shared) async throws -> WordpressSettings {
        try await urlSession.fetchJsonData(
            WordpressSettings.self,
            url: settingsUrl,
            dateDecodingStrategy: .wordpressDate
        )
    }
    
    public func fetchById<T: WordpressItem>(
        urlSession: URLSession = .shared,
        _ type: T.Type,
        id: Int
    ) async throws -> T {
        let url = restAPIv2Url
            .appendingPathComponent(type.urlComponent)
            .appendingPathComponent("\(id)")
        
        return try await urlSession.fetchJsonData(T.self, url: url)
    }
    
    public func itemStream<T: WordpressItem>(
        _ request: WordpressRequest<T>
    ) async throws -> AsyncThrowingStream<T, Error> {
        let urls = try await fetchPaginatedUrls(request)
        return await itemStream(T.self, urls: urls)
    }
    
    public func postStream(_ request: WordpressRequest<WordpressPost>? = nil) async throws -> AsyncThrowingStream<WordpressPost, Error> {
        try await itemStream(request ?? WordpressPost.request())
    }
    
    public func pageStream(_ request: WordpressRequest<WordpressPage>? = nil) async throws -> AsyncThrowingStream<WordpressPage, Error> {
        try await itemStream(request ?? WordpressPage.request())
    }
    
    public func categoryStream(_ request: WordpressRequest<WordpressCategory>? = nil) async throws -> AsyncThrowingStream<WordpressCategory, Error> {
        try await itemStream(request ?? WordpressCategory.request())
    }
    
    public func fetchItems<T: WordpressItem>(
        _ request: WordpressRequest<T>
    ) async throws -> [T] {
        let urls = try await fetchPaginatedUrls(request)
        return try await fetchItems(urlSession: request.urlSession, T.self, urls: urls)
    }
    
    public func fetchItems<T: WordpressItem>(
        _ type: T.Type
    ) async throws -> [T] {
        try await fetchItems(T.self.request())
    }
    
    public func fetchPosts(_ request: WordpressRequest<WordpressPost> = WordpressPost.request()) async throws -> [WordpressPost] {
        try await fetchItems(request)
    }
    
    public func fetchPages(_ request: WordpressRequest<WordpressPage> = WordpressPage.request()) async throws -> [WordpressPage] {
        try await fetchItems(request)
    }
    
    public func fetchCategories(_ request: WordpressRequest<WordpressCategory> = WordpressCategory.request()) async throws -> [WordpressCategory] {
        try await fetchItems(request)
    }
}
