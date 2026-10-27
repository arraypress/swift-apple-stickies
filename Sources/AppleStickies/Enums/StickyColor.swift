//
//  StickyColor.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A note's colour: Stickies' Color menu.
public enum StickyColor: String, Sendable, Codable, CaseIterable, Hashable {
    /// Yellow, Stickies' first colour.
    case yellow
    /// Blue.
    case blue
    /// Green.
    case green
    /// Pink.
    case pink
    /// Purple.
    case purple
    /// Gray.
    case gray
    /// A colour that is none of Stickies' own.
    case other
}
