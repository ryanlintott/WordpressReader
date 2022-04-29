//
//  WordpressExamples.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

public extension RenderedContent {
    static let example = RenderedContent(rendered: "Example rendered content")
}

public extension WordpressPost {
    static let example = WordpressPost(id: 100, link: "https://example.com", slug: "Example", date_gmt: Date(), modified_gmt: Date(),  title: .example, content: .example, excerpt: .example, categories: [], tags: [])
}

public extension WordpressPage {
    static let example = WordpressPage(id: 100, link: "https://example.com", slug: "ExampleWord", date_gmt: Date(), modified_gmt: Date(), title: .example, content: .example, excerpt: .example)
}

public extension WordpressCategory {
    static let example = WordpressCategory(id: 1, link: "https://example.com", slug: "example-category", count: 1, name: "example category", description: "Category description")
}

public extension WordpressTag {
    static let example = WordpressTag(id: 1, link: "https://example.com", slug: "example-tag", count: 1, name: "example tag", description: "Tag description")
}

public extension WordpressIcon {
    static let example = WordpressIcon(img: "https://example.com", ico: "https://example.com")
}

public extension WordpressLogo {
    static let example = WordpressLogo(id: 1, url: "https://example.com")
}

public extension WordpressSettings {
    static let example = WordpressSettings(ID: 1, name: "Example", description: "Example Description", URL: "https://example.com", icon: .example, logo: .example)
}
