//
//  WordpressDate.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2022-04-18.
//

import Foundation

/// An empty enum for storing Wordpress date formatters
enum WordpressDate {
    /// Date formatter for Wordpress style dates
    ///
    /// Details: https://core.trac.wordpress.org/ticket/41032
    static let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    /// Strategy for decoding Wordpress style dates.
    /// - Parameter decoder: Decoder to apply strategy to.
    /// - Returns: Decoded date.
    static func dateDecodingStrategy(_ decoder: Decoder) throws -> Date {
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
    
    /// Strategy for encoding Wordpress style dates.
    /// - Parameters:
    ///   - date: Date to encode.
    ///   - encoder: Encoder to apply strategy to.
    static func dateEncodingStrategy(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(formatter.string(from: date))
    }
}

extension JSONDecoder.DateDecodingStrategy {
    /// Wordpress style date decoder.
    static var wordpressDate: JSONDecoder.DateDecodingStrategy {
        .custom(WordpressDate.dateDecodingStrategy)
    }
}

extension JSONEncoder.DateEncodingStrategy {
    /// Wordpress style date encoder.
    static var wordpressDate: JSONEncoder.DateEncodingStrategy {
        .custom(WordpressDate.dateEncodingStrategy)
    }
}
