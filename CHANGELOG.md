# Changelog

## 1.0.4 - 2026-09-03

### Breaking Changes

- The `WordpressSite` initializer now returns nil when a domain isn't a valid host, instead of crashing later when `siteURL`, `postURL(id:)`, `pageURL(id:)` or `categoryURL(id:)` is used. Domains holding a scheme, path, port or an invalid character are rejected; they already produced unusable REST API URLs.

### Added

- `WordpressReaderErrorProtocol`, adopted by `WordpressReaderError` and each of its nested error types. Catching it handles every error thrown by this package, which catching `WordpressReaderError` alone never did.

### Changed

- `WordpressQueryItem` now hashes by name and value to match its equality, and sorts by name and then value so items sharing a name have a stable order.

### Fixed

- `fetch(_:maxConcurrentTasks:)` now returns items in page order. Batches were previously concatenated as their pages completed, so results could ignore the order requested by the `order` and `orderby` query items.
- `WordpressQueryItem.orderBy` now sends the Wordpress `orderby` parameter instead of `orderBy`, which Wordpress silently ignored.
- `WordpressRequest` now keeps a single query item per name, so a request holding two items with the same name (two `perPage` values, for example) no longer sends duplicate URL query parameters. A `page` inside the query items still takes priority over the requested page.
- Corrected the `WordpressOrder` documentation. `asc` sorts strings A - Z and `desc` sorts them Z - A.
- Fixed the example app's error descriptions, which never matched the nested WordpressReader error types.
- The example app no longer force unwraps an item link when building its URL.

## 1.0.3 - 2026-08-19

### Added

- DocC documentation catalog with a landing page introducing the package and curating the public API into topic groups.
- Link and badge in the readme pointing to the documentation on the Swift Package Index.

## 1.0.2 - 2026-08-17

### Breaking Changes

- Raised the minimum supported watchOS from 8 to 9.

### Fixed

- Moved the xcworkspace file inside the example app so the package builds correctly using swift build.

## 1.0.1 - 2026-08-14

### Changed

- Updated readme removing Twitter and adding Bluesky
- Updated example app to latest Xcode project settings.

### Fixed

- Removed unreferenced view from example app so it builds without errors.
- ContentView in example app now properly describes what the package does.

## 1.0.0 - 2026-08-14

### Breaking Changes

- Removed the deprecated closure-based `WordpressSite` fetch methods. Use the async `fetchSettings(urlSession:)`, `fetchById(urlSession:_:id:)`, `stream(_:maxConcurrentTasks:)`, and `fetch(_:maxConcurrentTasks:)` methods instead.

### Changed

- Removed the closure-based path from the example app. The example now demonstrates the async APIs exclusively.

## 0.5.1 - 2026-08-14

### Added

- Added github actions to test Swift 6 compatibility and test on all platforms

## 0.5.0 - 2026-08-14

### Breaking Changes

- Updated the package to Swift tools 6.0.
- Raised the minimum supported platforms to iOS 15, macOS 12, watchOS 8, and tvOS 15. visionOS remains at version 1.
- Changed the default maximum number of concurrent pagination tasks from unlimited to 8. Explicit values are now clamped to a minimum of 1 instead of 2.

### Deprecation Migration

The closure-based fetch APIs remain available in 0.5.0 but will be removed in 1.0.0. Upgrade to 0.5.0 first and resolve these deprecation warnings before updating to 1.0.0:

- Replace `fetchSettings(completion:)` with the async `fetchSettings(urlSession:)` method.
- Replace `fetchById(_:id:completion:)` with the async `fetchById(urlSession:_:id:)` method.
- Replace the batch-completion `fetch`, `fetchContent`, and `fetchItems` methods with `stream(_:maxConcurrentTasks:)`. Create a `WordpressRequest` first when migrating from `fetchContent`.
- Replace `fetchAllItems(_:completion:)` with `fetch(_:maxConcurrentTasks:)`.

### Added

- Added `WordpressSite.streamPages(_:maxConcurrentTasks:)`, which includes each page number with its batch. Pages are emitted as their requests complete and may arrive out of order.
- Added `WordpressSite.postURL(id:)` and `WordpressSite.categoryURL(id:)` for creating public navigation URLs from item IDs.
- Added a shared `WordpressReader.xcworkspace` and `WordpressReader Development` scheme for package and example-app development.
- Added Swift Package Index configuration for building and hosting the package's DocC documentation.

### Changed

- Pagination now uses the decoded starting-page response when reading the total-page count instead of requesting that page a second time.
- Updated the example app to load all content concurrently, preserve sorted post and page arrays while batches arrive, use the new ID-based URL helpers, and use `AsyncImage`.
- Converted the example app's source groups to filesystem-synchronized folders.
- Expanded the `WordpressDate` documentation and clarified pagination, batch-order, and WordPress `per_page` default behavior in the API documentation and README.

### Fixed

- Fixed paginated requests with a `startPage` other than 1 so the starting page is fetched first and included in the results.
- Fixed `fetch(_:maxConcurrentTasks:)` when called with a Wordpress item type so it forwards the requested concurrency limit.
- Fixed `WordpressRequest` initialization so generated `_fields` always replace caller-supplied field values while preserving other query items.
