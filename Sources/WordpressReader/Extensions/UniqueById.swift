//
//  UniqueById.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-07-23.
//

import Foundation

@available (iOS 13, macOS 10.15, *)
internal protocol UniqueById: Identifiable, Hashable { }

@available (iOS 13, macOS 10.15, *)
internal extension UniqueById {
  func hash(into hasher: inout Hasher) {
    hasher.combine(String(describing: Self.self))
    hasher.combine(id)
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}
