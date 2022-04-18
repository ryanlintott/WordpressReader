//
//  WordpressDate.swift
//  
//
//  Created by Ryan Lintott on 2022-04-18.
//

import Foundation

enum WordpressDate {
    /// Formatter for Wordpress dates
    ///
    /// Details: https://core.trac.wordpress.org/ticket/41032
    static let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    static func decodedDate(_ decoder: Decoder) throws -> Date {
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

    static func encodeDate(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(formatter.string(from: date))
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static var wordpressDate: JSONDecoder.DateDecodingStrategy {
        .custom(WordpressDate.decodedDate)
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static var wordpressDateFormatter: JSONEncoder.DateEncodingStrategy {
        .custom(WordpressDate.encodeDate)
    }
}
