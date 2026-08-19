# ``WordpressReader``

A simple asynchronous way to download and decode public Wordpress content.

## Overview

WordpressReader is built around ``WordpressSite``, a type that provides API access to any Wordpress.com site. Describe what you want with a ``WordpressRequest``, narrowed by a set of ``WordpressQueryItem``, then fetch posts, pages, categories, or tags asynchronously:

```swift
let site = WordpressSite(domain: "oldenglishwordhord.com", name: "Old English Wordhord")

let request = WordpressRequest.posts([.postedAfter(aWeekAgo), .order(.asc), .perPage(10)])
let posts = try await site.fetch(request)
```

Requests are paginated. ``WordpressSite/fetch(_:maxConcurrentTasks:)-(WordpressRequest<T>,_)`` gets pages in parallel and returns once they're all done, while ``WordpressSite/stream(_:maxConcurrentTasks:)`` and ``WordpressSite/streamPages(_:maxConcurrentTasks:)`` deliver each batch as its page completes.

Requires iOS 15+, macOS 12+, watchOS 9+, tvOS 15+, or visionOS 1+. Sites hosted outside Wordpress.com are not supported yet.

For a feature-by-feature guide with examples, see the [README](https://github.com/ryanlintott/WordpressReader), and the `Example` folder in the [repository](https://github.com/ryanlintott/WordpressReader) for a demo app.

## Topics

### Sites

- ``WordpressSite``
- ``WordpressSettings``
- ``WordpressIcon``
- ``WordpressLogo``

### Content

- ``WordpressPost``
- ``WordpressPage``
- ``WordpressCategory``
- ``WordpressTag``
- ``RenderedContent``

### Requests

- ``WordpressRequest``
- ``WordpressQueryItem``
- ``WordpressOrder``
- ``WordpressOrderBy``

### Protocols

- ``WordpressItem``
- ``WordpressContent``
- ``WordpressTaxonomy``
- ``ParameterLabels``

### Errors

- ``WordpressReaderError``
