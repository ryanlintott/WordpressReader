//
//  WordpressSite.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

public enum WordpressOrderBy: String {
    /// (Default) Date an item was posted
    case date
    
    /// Date an item was modified
    case modified
}

public enum WordpressOrder: String {
    /// Ascending order. Loads oldest dates first
    case asc
    
    /// (Default) Descending order. Loads newest dates first
    case desc
}

/// A type that allows API access to a provided site on Wordpress.com
///
/// Does not yet work for sites hosted outside Wordpress.com.
public struct WordpressSite {
    /// Site domain excluding http or other prefix.
    ///
    /// Example: `"example.com"`
    public let domain: String
    
    /// Name of the site. (Just used as a label)
    public let name: String
    
    /// URL to access REST API v1.1 for this site
    public let restAPIv1_1Url: URL
    
    /// URL to access REST API v2 for this site
    public let restAPIv2Url: URL
    
    /// Creates a type that allows API access to the provided wordpress.com domain
    /// - Parameters:
    ///   - domain: Wordpress site domain. Example: "example.com"
    ///   - name: Name of the site.
    public init(domain: String, name: String) {
        self.domain = domain
        self.name = name
        restAPIv1_1Url = Self.wordpressDotComRestAPIv1_1Prefix.appendingPathComponent(domain)
        restAPIv2Url = Self.wordpressDotComRestAPIv2Prefix.appendingPathComponent(domain)
    }
    
    /// Prefix for accessing wordpress REST API v1.1
    static let wordpressDotComRestAPIv1_1Prefix = URL(staticString: "https://public-api.wordpress.com/rest/v1.1/sites")
    /// Prefix for accessing wordpress REST API v2
    static let wordpressDotComRestAPIv2Prefix = URL(staticString: "https://public-api.wordpress.com/wp/v2/sites")
    static let totalPagesHeader: String = "X-WP-TotalPages"
    
    /// URL to use when accessing site settings
    var settingsUrl: URL {
        restAPIv1_1Url
    }
    
    public func fetchSettings(completion: @escaping (Result<WordpressSettings, Error>) -> Void) {
        let gmtDateFormatter: DateFormatter
        do {
            gmtDateFormatter = try self.gmtDateFormatter
        } catch(let error) {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.fetchJsonData(WordpressSettings.self, url: settingsUrl, dateDecodingStrategy: .formatted(gmtDateFormatter)) { result in
            completion(result)
        }
    }
    
    public func fetchById<T: WordpressItem>(_ type: T.Type, id: Int, completion: @escaping (Result<T, Error>) -> Void) {
        let url = restAPIv2Url
            .appendingPathComponent(type.urlComponent)
            .appendingPathComponent("\(id)")
        print("url: \(url)")
        URLSession.shared.fetchJsonData(T.self, url: url) { result in
            completion(result)
        }
    }
    
    @available(*, renamed: "fetchContent(_:postedAfter:postedBefore:modifiedAfter:modifiedBefore:orderBy:order:startPage:perPage:maxNumPages:completion:)")
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
        if let postedAfter = postedAfter {
            queryItems.append(URLQueryItem(name: "after", value: Self.isoDateFormatter.string(from: postedAfter)))
        }
        if let postedBefore = postedBefore {
            queryItems.append(URLQueryItem(name: "before", value: Self.isoDateFormatter.string(from: postedBefore)))
        }
        if let modifiedAfter = modifiedAfter {
            queryItems.append(URLQueryItem(name: "modified_after", value: Self.isoDateFormatter.string(from: modifiedAfter)))
        }
        if let modifiedBefore = modifiedBefore {
            queryItems.append(URLQueryItem(name: "modified_before", value: Self.isoDateFormatter.string(from: modifiedBefore)))
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
    
    public func fetchItems<T: WordpressItem>(_ type: T.Type, batchCompletion: @escaping (Result<[T], Error>) -> Void, completion: (() -> Void)? = nil) {
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
    
    public func fetchAllItems<T: WordpressItem>(_ type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
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
    
    public func fetchWithPagination<T: WordpressItem>(urlComponents: URLComponents, startPage: Int = 1, maxNumPages: Int? = nil, batchCompletion: @escaping (Result<[T], Error>) -> Void, completion: (() -> Void)? = nil) {
        guard let url = urlComponents.url else {
            print("ERROR - bad URL from urlComponents")
            return
        }

        URLSession.shared.fetchHeader(url: url, forHTTPHeaderField: Self.totalPagesHeader) { result in
            switch result {
            case .success(let result):
                let gmtDateFormatter: DateFormatter
                do {
                    gmtDateFormatter = try self.gmtDateFormatter
                } catch(let error) {
                    batchCompletion(.failure(error))
                    return
                }
                
                guard let totalPages = Int(result) else {
                    print("Error - numPages not a valid Int")
                    return
                }
                print("**WordpressReader fetchWithPagination \(T.self)**")
                print(url.absoluteURL)
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
                    URLSession.shared.fetchJsonData([T].self, url: pageUrl, dateDecodingStrategy: .formatted(gmtDateFormatter)) { result in
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
    
    private func processError(_ error: Error) {
        switch error {
        case NetworkError.badURL:
            print("Bad URL")
        case NetworkError.requestFailed:
            print("Network problems: \(error.localizedDescription)")
        case NetworkError.unknown(let description):
            print(description)
        case is DecodingError:
            print("Decoding error: \(error.localizedDescription)")
        default:
            print("Unknown error: \(error.localizedDescription)")
        }
    }
    
    private static let isoDateFormatter = ISO8601DateFormatter()
    
    static let isoDateValueBuilder: (Date) -> String = {
        ISO8601DateFormatter().string(from: $0)
    }
    
    public var gmtDateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        .wordpressDate
    }
    
    public var gmtDateFormatter: DateFormatter {
        get throws {
            guard let timeZone = Calendar.gmt?.timeZone else {
                throw WordpressError.APIError(details: "GMT timezone not accessible.")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            return dateFormatter
        }
    }
}
