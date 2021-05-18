//
//  Calendar-extension.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-10-02.
//

import Foundation

internal extension Calendar {
    static let gmt: Calendar? = {
        guard let timeZone = TimeZone(identifier: "UTC") ?? TimeZone(secondsFromGMT: 0) else {
            return nil
        }
        
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = timeZone
        return calendar
    }()
}
