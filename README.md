<img width="456" alt="WordpressReader Logo" src="https://user-images.githubusercontent.com/2143656/169389736-b28c8b3d-ec43-4714-a815-69d2e1672910.png">

[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FWordpressReader%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanlintott/WordpressReader)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FWordpressReader%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanlintott/WordpressReader)
![License - MIT](https://img.shields.io/github/license/ryanlintott/WordpressReader)
![Version](https://img.shields.io/github/v/tag/ryanlintott/WordpressReader?label=version)
![GitHub last commit](https://img.shields.io/github/last-commit/ryanlintott/WordpressReader)
[![Mastodon](https://img.shields.io/badge/mastodon-@ryanlintott-5c4ee4.svg?style=flat)](http://mastodon.social/@ryanlintott)
[![Twitter](https://img.shields.io/badge/twitter-@ryanlintott-blue.svg?style=flat)](http://twitter.com/ryanlintott)

# Overview
A simple asynchronous way to download and decode public Wordpress content.

# Demo App
The `Example` folder has an app that demonstrates the features of this package.

# Installation and Usage
This package is compatible with iOS 14+, macOS 11+, watchOS 7+, tvOS 14+, and visionOS.

1. In Xcode go to `File -> Add Packages`
2. Paste in the repo's url: `https://github.com/ryanlintott/WordpressReader` and select by version.
3. Import the package using `import WordpressReader`

# Is this Production-Ready?
Really it's up to you. I currently use this package in my own [Old English Wordhord app](https://oldenglishwordhord.com/app).

Additionally, if you find a bug or want a new feature add an issue and I will get back to you about it.

# Support
WordpressReader is open source and free but if you like using it, please consider supporting my work.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/X7X04PU6T)

- - -
# Features

Create an instance of WordpressSite for any Wordpress.com website:

```swift
let site = WordpressSite(domain: "oldenglishwordhord.com", name: "Old English Wordhord")
```

Fetch posts, pages, categories, or tags asynchronously:

```swift
let posts: [WordpressPost] = try await site.fetch(.posts())
let pages: [WordpressPage] = try await site.fetch(.pages())
let categories: [WordpressCategory] = try await site.fetch(.categories())
let tags: [WordpressTag] = try await site.fetch(.tags())
```

Add a set of WordpressQueryItem to narrow down your request:

```swift
let request = WordpressRequest.posts([.postedAfter(aWeekAgo), .order(.asc), perPage(10)])
let posts = try await site.fetch(request)
```

Wordpress queries may result in several pages of items. You can customize your WordpressRequest to get the first page out quickly:
```swift
var recentPosts = WordpressRequest.posts()
recentPosts.maxPages = 1

var remainingPosts = WordpressRequest.posts()
remainingPosts.startPage = 2

self.posts = try await site.fetch(recentPosts)
self.posts += try await site.fetch(remainingPosts)
```

The default .fetch() will get pages in parallel but only return when they're all done. If you want each batch in order as soon as they're ready, use an async stream:

```swift
for try await batch in try await site.stream(request) {
  self.posts += posts
}
```
