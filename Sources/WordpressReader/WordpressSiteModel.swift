//
//  WordpressSiteModel.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

enum WordpressError: Error {
    case APIError, BadArgument, BadURL
}

enum WordpressOrderBy: String {
    case date, modified
}

enum WordpressOrder: String {
    case asc, desc
}

@available (iOS 13, macOS 10.15, *)
class WordpressSite: ObservableObject {
    let siteUrl: String
    let name: String
    
    // only works for wordpress.com sites for now so always true
    let dotCom: Bool = true
    
    @Published var currentPost: WordpressPost? = nil
    @Published var posts = [WordpressPost]()
    @Published var pages = [WordpressPage]()
    @Published var categories = [WordpressCategory]()
    @Published var settings: WordpressSettings? = nil
    @Published var loading = false
    
    init(siteUrl: String, name: String) {
        self.siteUrl = siteUrl
        self.name = name
    }
    
    static let wordpressDotComRestAPIv2Prefix = URL(staticString: "https://public-api.wordpress.com/wp/v2/sites")
    static let wordpressDotComRestAPIv1_1Prefix = URL(staticString: "https://public-api.wordpress.com/rest/v1.1/sites")
    static let totalPagesHeader: String = "X-WP-TotalPages"
    
    var restAPIv1_1Url: URL {
        Self.wordpressDotComRestAPIv1_1Prefix.appendingPathComponent(siteUrl)
    }
    
    var restAPIv2Url: URL {
        Self.wordpressDotComRestAPIv2Prefix.appendingPathComponent(siteUrl)
    }
    
    var settingsUrl: URL {
        return restAPIv1_1Url
    }
    
    func loadAll(completion: (() -> Void)? = nil) {
//        loadSettings {
//            self.loadPosts {
//                self.loadPages {
//                    self.loadCategories {
//                        completion?()
//                    }
//                }
//            }
//        }
    }
    
    func loadSettings(completion: (() -> Void)? = nil) {
        URLSession.fetchJsonData(WordpressSettings.self, url: settingsUrl, dateDecodingStrategy: .formatted(Self.gmtDateFormatter)) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.settings = result
                }
            case .failure(let error):
                print("Error loadSettings")
                self.processError(error)
            }
            completion?()
        }
    }
    
    func fetchById<T: WordpressItem>(_ type: T.Type, id: Int, completion: @escaping (Result<T, Error>) -> Void) {
        let url = restAPIv2Url
            .appendingPathComponent(type.urlComponent)
            .appendingPathComponent("\(id)")
        
        URLSession.fetchJsonData(T.self, url: url) { result in
            completion(result)
        }
    }
    
    func fetchContent<T: WordpressContent>(_ type: T.Type, postedAfter: Date? = nil, postedBefore: Date? = nil, orderBy: WordpressOrderBy? = nil, order: WordpressOrder? = nil, startPage: Int = 1, perPage: Int? = nil, maxNumPages: Int? = nil, batchCompletion: @escaping (Result<[T], Error>) -> Void, completion: (() -> Void)? = nil) {
        guard startPage > 0 else {
            print("ERROR - start page must be greater than zero")
            return
        }
        let baseUrl = restAPIv2Url.appendingPathComponent(type.urlComponent)
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("ERROR - bad URL")
            return
        }
        
        let fields = T.parameterLabels
        
        var queryItems = [URLQueryItem]()
        if !fields.isEmpty {
            queryItems.append(URLQueryItem(name: "_fields", value: fields.joined(separator: ",")))
        }
        if let after = postedAfter {
            queryItems.append(URLQueryItem(name: "after", value: Self.isoDateFormatter.string(from: after)))
        }
        if let before = postedBefore {
            queryItems.append(URLQueryItem(name: "before", value: Self.isoDateFormatter.string(from: before)))
        }
        if let orderBy = orderBy {
            queryItems.append(URLQueryItem(name: "orderBy", value: orderBy.rawValue))
        }
        if let order = order {
            queryItems.append(URLQueryItem(name: "order", value: order.rawValue))
        }
        if let perPage = perPage {
            queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
        }
        urlComponents.queryItems = queryItems
        
        fetchWithPagination(urlComponents: urlComponents, batchCompletion: batchCompletion, completion: completion)
    }
    
    func fetchItems<T: WordpressItem>(_ type: T.Type, batchCompletion: @escaping (Result<[T], Error>) -> Void, completion: (() -> Void)? = nil) {
        let baseUrl = restAPIv2Url.appendingPathComponent(T.urlComponent)
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("ERROR - bad URL")
            return
        }
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "per_page", value: "\(100)"))

        urlComponents.queryItems = queryItems
        
        fetchWithPagination(urlComponents: urlComponents, batchCompletion: batchCompletion, completion: completion)
    }
    
    func fetchAllItems<T: WordpressItem>(_ type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        var allItems = [T]()
        var fetchError: Error? = nil
        
        fetchItems(type) { result in
            switch result {
            case .success(let items):
                allItems += items
            case .failure(let error):
                print("Error loadPosts")
                fetchError = error
            }
        } completion: {
            if let fetchError = fetchError {
                completion(.failure(fetchError))
            } else {
                completion(.success(allItems))
            }
        }
    }
    
    private func fetchWithPagination<T: WordpressItem>(urlComponents: URLComponents, startPage: Int = 1, maxNumPages: Int? = nil, batchCompletion: @escaping (Result<[T], Error>) -> Void, completion: (() -> Void)? = nil) {
        guard let url = urlComponents.url else {
            print("ERROR - bad URL from urlComponents")
            return
        }
//        print("fetchWithPagination")
//        print(url.absoluteURL)
        URLSession.fetchHeader(url: url, forHTTPHeaderField: Self.totalPagesHeader) { result in
            switch result {
            case .success(let result):
                guard let totalPages = Int(result) else {
                    print("Error - numPages not a valid Int")
                    return
                }
                print(url.absoluteURL)
                print(totalPages)
                guard totalPages > 0 else {
                    completion?()
                    print("zero pages")
                    return
                }
                guard startPage <= totalPages else {
                    print("Error - requested page higher than available pages")
                    return
                }
                
                let endPage = min(totalPages, startPage + (maxNumPages ?? totalPages) - 1)
                var sessions = endPage - startPage + 1
                for page in startPage...endPage {
                    var pageUrlComponents = urlComponents
                    pageUrlComponents.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
                    guard let pageUrl = pageUrlComponents.url else {
                        print("ERROR - bad URL from pageUrlComponents")
                        return
                    }
                    URLSession.fetchJsonData([T].self, url: pageUrl, dateDecodingStrategy: .formatted(Self.gmtDateFormatter)) { result in
                        batchCompletion(result)
                        sessions -= 1
                        if sessions == 0 {
                            completion?()
                        }
                    }
                }
            case .failure(let error):
                print("Error loadPosts")
                self.processError(error)
            }
        }
    }
    
    // Loads a single post by id
    func loadPost(id: Int, completion: (() -> Void)? = nil) {
        fetchById(WordpressPost.self, id: id) { result in
            switch result {
            case .success(let post):
                DispatchQueue.main.async {
                    self.currentPost = post
                }
            case .failure(let error):
                print("Error loadPost")
                self.processError(error)
            }
            completion?()
        }
    }
    
    // Loads up to 100 posts without batching
    func loadPosts(amount: Int = 10, completion: (() -> Void)? = nil) {
        fetchContent(WordpressPost.self, perPage: amount, maxNumPages: 1) { result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self.posts = posts
                }
            case .failure(let error):
                print("Error loadPosts")
                self.processError(error)
            }
        }
    }
    
    // Loads up to 100 pages without batching
    func loadPages(amount: Int = 10, completion: (() -> Void)? = nil) {
        fetchContent(WordpressPage.self, perPage: amount, maxNumPages: 1) { result in
            switch result {
            case .success(let pages):
                DispatchQueue.main.async {
                    self.pages = pages
                }
            case .failure(let error):
                print("Error loadPosts")
                self.processError(error)
            }
        }
    }
    
    // Loads all categories using batching
    func loadCategories(completion: (() -> Void)? = nil) {
        fetchAllItems(WordpressCategory.self) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.categories = result
                }
            case .failure(let error):
                print("Error loadCategories")
                self.processError(error)
            }
            completion?()
        }
    }
    
    func processError(_ error: Error) {
        switch error {
        case NetworkError.badURL:
            print("Bad URL")
        case NetworkError.requestFailed:
            print("Network problems: \(error.localizedDescription)")
        case NetworkError.unknown:
            print("Unknown network error: \(error.localizedDescription)")
        case is DecodingError:
            print("Decoding error: \(error.localizedDescription)")
        default:
            print("Unknown error: \(error.localizedDescription)")
        }
    }
    
    static let isoDateFormatter = ISO8601DateFormatter()
    
    static let gmtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        if let timeZone = Calendar.gmt?.timeZone {
            dateFormatter.timeZone = timeZone
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter
    }()
}
