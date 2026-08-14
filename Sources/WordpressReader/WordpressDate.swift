//
//  WordpressDate.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-18.
//

import Foundation

/// A namespace for date coding strategies used with WordPress REST API payloads.
///
/// WordPress returns post and page timestamps such as `date_gmt` and
/// `modified_gmt` in a fixed, whole-second representation that does not fully
/// conform to ISO 8601 or RFC 3339. These strategies provide compatibility with
/// that response format. Date-valued query parameters are encoded separately
/// using `ISO8601DateFormatter`.
enum WordpressDate {
    /// A formatter for the fixed, UTC timestamps returned in WordPress payloads.
    ///
    /// WordPress core emits these timestamps without timezone information even
    /// for fields whose names end in `_gmt`, so the formatter interprets them
    /// as UTC. See https://core.trac.wordpress.org/ticket/41032 for details.
    static let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    /// A strategy for decoding fixed-format dates from WordPress REST payloads.
    /// - Parameter decoder: Decoder to apply strategy to.
    /// - Returns: Decoded date.
    static func dateDecodingStrategy(_ decoder: any Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateAsString = try container.decode(String.self)

        guard let date = formatter.date(from: dateAsString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected date string to be Wordpress formatted."
            ))
        }
        
        return date
    }
    
    /// A strategy for encoding dates in the WordPress payload format.
    /// - Parameters:
    ///   - date: Date to encode.
    ///   - encoder: Encoder to apply strategy to.
    static func dateEncodingStrategy(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(formatter.string(from: date))
    }
}

extension JSONDecoder.DateDecodingStrategy {
    /// A decoder for fixed-format dates in WordPress REST payloads.
    static let wordpressDate: JSONDecoder.DateDecodingStrategy = .custom(WordpressDate.dateDecodingStrategy)
}

extension JSONEncoder.DateEncodingStrategy {
    /// An encoder for dates in the WordPress REST payload format.
    static let wordpressDate: JSONEncoder.DateEncodingStrategy = .custom(WordpressDate.dateEncodingStrategy)
}
