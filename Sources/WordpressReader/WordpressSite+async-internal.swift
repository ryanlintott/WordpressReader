//
//  WordpressSite+async-internal.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-27.
//

import Foundation

extension WordpressSite {
    /// Fetches the first requested page and returns it with page numbers and URLs for the remaining pages.
    /// - Parameter request: Request used to retrieve paginated items.
    /// - Returns: The first requested batch, when available, and page numbers and URLs for the remaining pages.
    /// - Throws: ``WordpressReaderError`` if there are URL errors, badly formatted query items, or if there is no totalPages value in the header.
    nonisolated func fetchPagination<T: WordpressItem>(
        _ request: WordpressRequest<T>
    ) async throws -> (firstBatch: [T]?, remainingPages: [(number: Int, url: URL)]) {
        let baseUrl = restAPIv2Url.appendingPathComponent(T.self.urlComponent)
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            throw WordpressReaderError.URLError.badURL(urlString: baseUrl.absoluteString)
        }
        
        let pageRange: ClosedRange<Int>?
        var firstBatch: [T]?
        
        if let page = request.queryItems.pages.first {
            pageRange = page...page
        } else {
            urlComponents.queryItems = request.urlQueryItems
            
            guard let url = urlComponents.url else {
                throw WordpressReaderError.URLError.badURLComponents
            }
            
            let header: String
            if request.startPage == 1 {
                let result = try await request.urlSession.fetchJsonDataAndResponse(
                    [T].self,
                    url: url,
                    dateDecodingStrategy: .wordpressDate
                )
                firstBatch = result.value

                guard let totalPagesHeader = result.response.value(forHTTPHeaderField: Self.totalPagesHeader) else {
                    throw WordpressReaderError.Network.badHeaderName(headerName: Self.totalPagesHeader)
                }
                header = totalPagesHeader
            } else {
                header = try await request.urlSession.fetchHeader(url: url, forHTTPHeaderField: Self.totalPagesHeader)
            }
            
            guard let totalPages = Int(header) else {
                throw WordpressReaderError.API.apiError(details: "Total pages in header not a valid Integer")
            }
            
            pageRange = request.pageRange(total: totalPages)
        }
        
        // Confirm all remaining page URLs are valid
        let remainingPages = try pageRange?.compactMap { page -> (number: Int, url: URL)? in
            if firstBatch != nil && page == 1 {
                return nil
            }

            var pageUrlComponents = urlComponents
            pageUrlComponents.queryItems = request.urlQueryItems(page)

            guard let url = pageUrlComponents.url else {
                throw WordpressReaderError.URLError.badURLComponents
            }
            return (page, url)
        } ?? []

        return (firstBatch, remainingPages)
    }
    
}
