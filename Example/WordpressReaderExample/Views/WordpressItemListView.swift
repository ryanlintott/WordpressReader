//
//  WordpressItemListView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI
import WordpressReader

struct WordpressItemListView<T: WordpressItem>: View {
    let title: String
    let items: [T]
    let loading: Bool
    
    func itemTitle(_ item: T) -> String {
        if let item = item as? WordpressPost {
            return item.titleCleaned
        } else if let item = item as? WordpressPage {
            return item.titleCleaned
        } else {
            return item.slug
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if loading {
                        ProgressView()
                    }
                    Text("Total: \(items.count)")
                }
                List(items, id: \.id) { item in
                    NavigationLink (
                        destination: WordpressItemView(item)
                    ) {
                        HStack {
                            Text(itemTitle(item))
                        }
                    }
                }
            }
            .navigationTitle(title)
        }
    }
}


struct WordpressItemListView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressItemListView(title: "Posts", items: [WordpressPost.example], loading: false)
        
        WordpressItemListView(title: "Pages", items: [WordpressPage.example], loading: true)
        
        WordpressItemListView(title: "Categories", items: [WordpressCategory.example], loading: false)
    }
}
