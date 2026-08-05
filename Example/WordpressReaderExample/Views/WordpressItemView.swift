//
//  WordpressItemView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI
import WordpressReader

struct WordpressItemView<T: WordpressItem>: View {
    let item: T
    
    init(_ item: T) {
        self.item = item
    }
    
    var title: String {
        if let item = item as? WordpressPost {
            return item.titleCleaned
        } else if let item = item as? WordpressPage {
            return item.titleCleaned
        } else {
            return item.slug
        }
    }

    var idURL: URL? {
        if item is WordpressPost {
            WordpressSite.wordhord.postURL(id: item.id)
        } else if item is WordpressPage {
            WordpressSite.wordhord.pageURL(id: item.id)
        } else if item is WordpressCategory {
            WordpressSite.wordhord.categoryURL(id: item.id)
        } else {
            nil
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("ID")) {
                if let idURL {
                    Link("\(item.id)", destination: idURL)
                } else {
                    Text("\(item.id)")
                }
            }
            
            Section(header: Text("Link")) {
                Link(item.link, destination: URL(string: item.link)!)
            }
            
            Section(header: Text("Slug")) {
                Text(item.slugCleaned)
            }
            
            if let content = item as? (any WordpressContent) {
                Section(header: Text("Date Posted")) {
                    Text(content.date_gmt, style: .date)
                }
                
                Section(header: Text("Date Modified")) {
                    Text(content.modified_gmt, style: .date)
                }
                
                Section(header: Text("Excerpt")) {
                    Text(content.excerptCleaned)
                }
                
                Section(header: Text("Content")) {
                    Text(content.contentHtml)
                }
                
            }
            if let post = item as? WordpressPost {
                Section(header: Text("Categories")) {
                    ForEach(post.categories, id: \.self) { id in
                        Text(String(id))
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(post.tags, id: \.self) { id in
                        Text(String(id))
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}

struct WordpressItemView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressItemView(WordpressPost.example)
        
        WordpressItemView(WordpressPage.example)
        
        WordpressItemView(WordpressCategory.example)
    }
}
