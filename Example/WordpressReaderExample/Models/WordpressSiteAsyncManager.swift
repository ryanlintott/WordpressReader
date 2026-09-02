//
//  WordpressSiteAsyncManager.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2022-03-29.
//

import Foundation
import WordpressReader

@MainActor
class WordpressSiteAsyncManager: ObservableObject {
    let site: WordpressSite
    
    @Published var singlePost: WordpressPost? = nil
    @Published var posts: [WordpressPost] = []
    @Published var pages: [WordpressPage] = []
    @Published var categories: [WordpressCategory] = []
    @Published var settings: WordpressSettings? = nil
    @Published var error: String? = nil
    
    init(site: WordpressSite) {
        self.site = site
    }
    
    func loadAll() async {
        let asyncStart = Date.now
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadSettings()
                print("Settings: \(Date.now.timeIntervalSince(asyncStart))")
            }
            
            group.addTask {
                await self.loadCategories()
                print("Categories: \(Date.now.timeIntervalSince(asyncStart))")
            }
            
            group.addTask {
                await self.loadPosts()
                print("AllPosts: \(Date.now.timeIntervalSince(asyncStart))")
            }

            group.addTask {
                await self.loadPages()
                print("Pages: \(Date.now.timeIntervalSince(asyncStart))")
            }
        }
        print("All done")
    }
    
    func loadSettings() async {
        do {
            settings = try await site.fetchSettings()
        } catch let error {
            processError(error)
        }
    }
    
    // Loads a single post by id
    func loadPost(id: Int) async {
        do {
            singlePost = try await site.fetchById(WordpressPost.self, id: id)
        } catch let error {
            processError(error)
        }
    }
    
    private static let perPage = WordpressQueryItem.perPage(100)
    
    /// Loads posts using an async stream
    func loadPosts() async {
        do {
            for try await batch in try await site.stream(.posts([.perPage(100)])) {
                posts = (posts + batch)
                    .reduce(into: [Int: WordpressPost]()) {
                        $0[$1.id] = $1
                    }
                    .values
                    .sorted { $0.date_gmt > $1.date_gmt }
            }
        } catch let error {
            processError(error)
        }
    }
    
    // Loads all pages
    func loadPages() async {
        do {
            pages = try await site.fetch(.pages([.perPage(100)]))
        } catch let error {
            processError(error)
        }
        
    }
    
    // Loads all categories
    func loadCategories() async {
        do {
            categories = try await site.fetch(.categories([.perPage(100)]))
        } catch let error {
            processError(error)
        }
    }
    
    func processError(_ error: Error) {
        self.error = errorString(error)
        print(error)
    }
    
    func errorString(_ error: Error) -> String {
        switch error {
        case WordpressReaderError.URLError.badURL:
            return "Bad URL"
        case WordpressReaderError.Network.requestFailed:
            return "Network problems: \(error.localizedDescription)"
        case WordpressReaderError.Network.unknown(let description):
            return "Unknown network error: \(description)"
        case is DecodingError:
            return "Decoding error: \(error.localizedDescription)"
        case is any WordpressReaderErrorProtocol:
            return "WordpressReader error: \(error.localizedDescription)"
        default:
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
