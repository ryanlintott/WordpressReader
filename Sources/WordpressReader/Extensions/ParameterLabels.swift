//
//  WordpressFields.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2020-10-16.
//

import Foundation

/// A type whose parameter labels can be accessed as an array of string values.
public protocol ParameterLabels {
    /// A single instance of this type used only to access parameter labels.
    ///
    /// Nested types must also conform to ParameterLabels
    ///
    ///      var labelMaker = MyType(id: 0, name: "", nestedType: .labelMaker)
    static var labelMaker: Self { get }
}

extension ParameterLabels {
    /// An array containing the label of each parameter for this type.
    static var parameterLabels: [String] {
        Mirror(reflecting: Self.labelMaker).children.compactMap(\.label)
    }
}
