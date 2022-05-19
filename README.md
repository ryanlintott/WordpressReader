
[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FWordpressReader%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanlintott/WordpressReader)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FWordpressReader%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanlintott/WordpressReader)
![License - MIT](https://img.shields.io/github/license/ryanlintott/WordpressReader)
![Version](https://img.shields.io/github/v/tag/ryanlintott/WordpressReader?label=version)
![GitHub last commit](https://img.shields.io/github/last-commit/ryanlintott/WordpressReader)
[![Twitter](https://img.shields.io/badge/twitter-@ryanlintott-blue.svg?style=flat)](http://twitter.com/ryanlintott)

# Overview
A simple asynchronous way to download and decode public Wordpress content.

# WordpressReaderExample
Check out the [example app](https://github.com/ryanlintott/WordpressReaderExample) to see how you can use this package in your iOS app.

# Installation
1. In XCode 12 go to `File -> Swift Packages -> Add Package Dependency` or in XCode 13 `File -> Add Packages`
2. Paste in the repo's url: `https://github.com/ryanlintott/WordpressReader` and select by version.

# Usage
Import the package using `import WordpressReader`

# Platforms
This package is compatible with iOS 14 or later.

# Is this Production-Ready?
Really it's up to you. I currently use this package in my own [Old English Wordhord app](https://oldenglishwordhord.com/app).

# Support
If you like this package, buy me a coffee to say thanks!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/X7X04PU6T)

- - -
# Details

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
