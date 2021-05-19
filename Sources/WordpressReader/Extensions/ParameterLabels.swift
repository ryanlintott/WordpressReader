//
//  WordpressFields.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-10-16.
//

import Foundation

public protocol ParameterLabels {
    static var labelMaker: Self { get }
}

public extension ParameterLabels {
    static var parameterLabels: [String] {
        Mirror(reflecting: Self.labelMaker).children.compactMap(\.label)
    }
}
