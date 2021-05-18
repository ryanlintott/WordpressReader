//
//  WordpressFields.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-10-16.
//

import Foundation

internal protocol ParameterLabels {
    static var labelMaker: Self { get }
}

internal extension ParameterLabels {
    static var parameterLabels: [String] {
        Mirror(reflecting: Self.labelMaker).children.compactMap(\.label)
    }
}
