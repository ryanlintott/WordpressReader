//
//  WordpressSiteAsyncView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2022-03-29.
//

import SwiftUI
import WordpressReader

struct WordpressSiteAsyncView: View {
    @StateObject var siteManager = WordpressSiteAsyncManager(site: .wordhord)
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
        defer { isLoading = false }
        await siteManager.loadAll()
    }
}

struct WordpressSiteAsyncView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSiteAsyncView()
    }
}
