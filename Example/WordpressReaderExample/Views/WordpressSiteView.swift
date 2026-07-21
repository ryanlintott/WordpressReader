//
//  WordpressSiteView.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-07-11.
//

import SwiftUI
import WordpressReader

struct WordpressSiteView: View {
    @StateObject var siteManager = WordpressSiteManager(site: .wordhord)
    @State private var isLoading: Bool = false
    
    var tabView: some View {
        WordpressSiteTabs(
            posts: siteManager.posts,
            pages: siteManager.pages,
            categories: siteManager.categories,
            settings: siteManager.settings,
            isLoading: isLoading
        )
    }
    
    var body: some View {
        tabView
            .task {
                await loadContent()
            }
    }
    
    func loadContent() async {
        isLoading = true
        await withCheckedContinuation { continuation in
            siteManager.loadRecentThenAll {
                continuation.resume()
            }
        }
        isLoading = false
    }
}

struct WordpressSiteView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSiteView()
    }
}
