import Foundation
import Testing
@testable import WordpressReader

struct WordpressReaderTests {
    @Test
    func supportedItemsCreateIDBasedURLs() {
        let site = WordpressSite(domain: "example.com", name: "Example")

        #expect(site.postURL(id: 42).absoluteString == "https://example.com?p=42")
        #expect(site.pageURL(id: 42).absoluteString == "https://example.com?page_id=42")
        #expect(site.categoryURL(id: 42).absoluteString == "https://example.com?cat=42")
    }

    @Test
    func requestAddsGeneratedFieldsDuringInitialization() {
        let request = WordpressRequest<WordpressCategory>()

        expectGeneratedFields(in: request)
    }

    @Test
    func requestPreservesOtherQueryItemsDuringInitialization() {
        let queryItem = WordpressQueryItem.order(.asc)
        let request = WordpressRequest<WordpressCategory>(queryItems: [queryItem])

        #expect(request.queryItems.contains(queryItem))
        expectGeneratedFields(in: request)
    }

    @Test
    func requestReplacesCallerSuppliedFieldsDuringInitialization() {
        let request = WordpressRequest<WordpressCategory>(
            queryItems: [
                .fields(["id"]),
                .custom(name: "_fields", value: "slug"),
            ]
        )

        expectGeneratedFields(in: request)
    }

    @Test
    func requestRestoresGeneratedFieldsAfterAssignmentAndMutation() {
        var request = WordpressRequest<WordpressCategory>()

        request.queryItems = [.fields(["id"])]
        expectGeneratedFields(in: request)

        request.queryItems.insert(.custom(name: "_fields", value: "slug"))
        expectGeneratedFields(in: request)
    }

    @Test
    func requestGeneratesExactlyOneFieldsURLQueryItem() {
        let request = WordpressRequest<WordpressCategory>(
            queryItems: [
                .fields(["id"]),
                .custom(name: "_fields", value: "slug"),
            ]
        )
        let fieldsQueryItems = request.urlQueryItems.filter { $0.name == "_fields" }

        #expect(fieldsQueryItems.count == 1)
        #expect(fieldsQueryItems.first?.value == WordpressCategory.parameterLabels.joined(separator: ","))
    }

    @Test
    func requestsWithDifferentCallerSuppliedFieldsNormalizeEquivalently() {
        let firstRequest = WordpressRequest<WordpressCategory>(queryItems: [.fields(["id"])])
        let secondRequest = WordpressRequest<WordpressCategory>(
            queryItems: [.custom(name: "_fields", value: "slug")]
        )

        #expect(firstRequest == secondRequest)
    }

    @Test(.tags(.networking))
    func streamEmitsBatchesInCompletionOrder() async throws {
        let (site, request, urlSession) = makeRequest()
        defer { urlSession.invalidateAndCancel() }

        var pageIDs: [[Int]] = []
        for try await batch in try await site.stream(request, maxConcurrentTasks: 2) {
            pageIDs.append(batch.map(\.id))
        }

        #expect(pageIDs == [[1], [3], [2]])
    }

    @Test(.tags(.networking))
    func streamPagesFetchesStartingPageBeforeRemainingPages() async throws {
        let (site, request, urlSession) = makeRequest(startPage: 2)
        defer { urlSession.invalidateAndCancel() }

        var pageNumbers: [Int] = []
        var pageIDs: [[Int]] = []
        for try await (pageNumber, batch) in try await site.streamPages(request, maxConcurrentTasks: 2) {
            pageNumbers.append(pageNumber)
            pageIDs.append(batch.map(\.id))
        }

        #expect(pageNumbers == [2, 3])
        #expect(pageIDs == [[2], [3]])
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

    private func expectGeneratedFields(
        in request: WordpressRequest<WordpressCategory>,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let fields = request.queryItems.filter { $0.name == "_fields" }
        #expect(fields.count == 1, sourceLocation: sourceLocation)
        #expect(
            fields.first?.value == WordpressCategory.parameterLabels.joined(separator: ","),
            sourceLocation: sourceLocation
        )
    }
}

extension Tag {
    @Tag static var networking: Self
}

private final class OutOfOrderPagesURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let pageValue = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "page" })?
            .value
        guard let page = pageValue.flatMap(Int.init) else {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
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
