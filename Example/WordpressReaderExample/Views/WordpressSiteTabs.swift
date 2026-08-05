//
//  WordpressSiteTabs.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2024-07-24.
//

import SwiftUI
import WordpressReader

enum WordpressSiteViewTab: String {
    case posts, site, pages, categories
}

struct WordpressSiteTabs: View {
    @State private var selection: WordpressSiteViewTab = .posts
    let posts: [WordpressPost]
    let pages: [WordpressPage]
    let categories: [WordpressCategory]
    let settings: WordpressSettings?
    let isLoading: Bool
    
    var body: some View {
        TabView(selection: $selection) {
            WordpressItemListView(title: "Posts", items: posts, loading: isLoading)
                .tabItem {
                    Label("Posts", systemImage: "globe")
                }
                .tag(WordpressSiteViewTab.posts)
            
            WordpressItemListView(title: "Pages", items: pages, loading: isLoading)
                .tabItem {
                    Label("Pages", systemImage: "doc.plaintext")
                }
                .tag(WordpressSiteViewTab.pages)
            
            WordpressItemListView(title: "Categories", items: categories, loading: isLoading)
                .tabItem {
                    Label("Categories", systemImage: "tag")
                }
                .tag(WordpressSiteViewTab.categories)
            
            WordpressSettingsView(settings: settings)
                .tabItem {
                    Label("Site", systemImage: "gear")
                }
                .tag(WordpressSiteViewTab.site)
        }
    }
}

#Preview {
    WordpressSiteTabs(posts: [], pages: [], categories: [], settings: nil, isLoading: false)
}
