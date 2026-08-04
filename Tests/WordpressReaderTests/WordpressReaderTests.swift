import Foundation
import XCTest
@testable import WordpressReader

final class WordpressReaderTests: XCTestCase {
    func testStreamEmitsBatchesInCompletionOrder() async throws {
        let (site, request, urlSession) = makeRequest()
        defer { urlSession.invalidateAndCancel() }

        var pageIDs: [[Int]] = []
        for try await batch in try await site.stream(request, maxConcurrentTasks: 2) {
            pageIDs.append(batch.map(\.id))
        }

        XCTAssertEqual(pageIDs, [[1], [3], [2]])
    }

    func testStreamPagesIncludesPageNumbersInCompletionOrder() async throws {
        let (site, request, urlSession) = makeRequest(startPage: 2)
        defer { urlSession.invalidateAndCancel() }

        var pageNumbers: [Int] = []
        var pageIDs: [[Int]] = []
        for try await (pageNumber, batch) in try await site.streamPages(request, maxConcurrentTasks: 2) {
            pageNumbers.append(pageNumber)
            pageIDs.append(batch.map(\.id))
        }

        XCTAssertEqual(pageNumbers, [3, 2])
        XCTAssertEqual(pageIDs, [[3], [2]])
    }

    private func makeRequest(
        startPage: Int = 1
    ) -> (WordpressSite, WordpressRequest<WordpressCategory>, URLSession) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [OutOfOrderPagesURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        let site = WordpressSite(domain: "example.com", name: "Example")
        var request = WordpressRequest<WordpressCategory>()
        request.urlSession = urlSession
        request.startPage = startPage
        return (site, request, urlSession)
    }
}

private final class OutOfOrderPagesURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let page = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "page" })?
            .value
            .flatMap(Int.init) ?? 1
        let delay = page == 2 ? 0.2 : 0.01

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [self] in
            let data = Data("""
                [{"id":\(page),"link":"","slug":"page-\(page)","count":0,"name":"","description":""}]
                """.utf8)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["X-WP-TotalPages": "3"]
            )!

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
