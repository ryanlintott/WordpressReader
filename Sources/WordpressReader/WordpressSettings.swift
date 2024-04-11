//
//  WordpressSettings.swift
//  WordpressReader
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation

/// A Wordpress Settings object
///
/// This type has a subset of parameters that match the names of those in the (deprecated) Wordpress Rest API V1
public struct WordpressSettings: Codable, Identifiable, Hashable, Equatable, Sendable, ParameterLabels {
    public static let labelMaker = Self(ID: 0, name: "", description: "", URL: "", icon: .labelMaker, logo: .labelMaker)
    
    /// Unique identifier for the settings
    public var ID: Int
    /// Name of the Wordpress Site
    public var name: String
    /// Description of the Wordpress Site
    public var description: String
    /// URL for the Wordpress Site
    public var URL: String
    /// Icon for the Wordpress Site
    public var icon: WordpressIcon
    /// Logo for the Wordpress Site
    public var logo: WordpressLogo
    
    /// Unique identifier required for identifiable conformance (same value as ID)
    public var id: Int { self.ID }
}
