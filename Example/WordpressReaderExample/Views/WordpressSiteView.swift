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
    @State private var task: Task<Void, Never>? = nil
    
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
        if #available(iOS 15, macOS 12, tvOS 15, *) {
            tabView
                .task {
                    await loadContent()
                }
        } else {
            tabView
                .onAppear {
                    task = Task {
                        await loadContent()
                        task = nil
                    }
                }
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
