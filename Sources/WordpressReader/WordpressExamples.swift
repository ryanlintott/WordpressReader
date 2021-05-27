//
//  WordpressExamples.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-09-15.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
public extension RenderedContent {
    static let example = RenderedContent(rendered: "Example rendered content")
}

@available (iOS 13, macOS 10.15, *)
public extension WordpressPost {
    static let example = WordpressPost(id: 100, date_gmt: Date(), modified_gmt: Date(), slug: "Example", link: "https://example.com", title: .example, content: .example, excerpt: .example, categories: [], tags: [])
}

@available (iOS 13, macOS 10.15, *)
public extension WordpressPage {
    static let example = WordpressPage(id: 100, date_gmt: Date(), modified_gmt: Date(), slug: "ExampleWord", link: "https://example.com", title: .example, content: .example, excerpt: .example)
}

@available (iOS 13, macOS 10.15, *)
public extension WordpressCategory {
    static let example = WordpressCategory(id: 1, count: 1, description: "Category description", link: "https://example.com", name: "example category", slug: "example-category")
}

@available (iOS 13, macOS 10.15, *)
public extension WordpressIcon {
    static let example = WordpressIcon(img: "https://example.com", ico: "https://example.com")
}

@available (iOS 13, macOS 10.15, *)
public extension WordpressLogo {
    static let example = WordpressLogo(id: 1, url: "https://example.com")
}

@available (iOS 13, macOS 10.15, *)
public extension WordpressSettings {
    static let example = WordpressSettings(ID: 1, name: "Example", description: "Example Description", URL: "https://example.com", icon: .example, logo: .example)
}
