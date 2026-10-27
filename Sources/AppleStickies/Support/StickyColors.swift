//
//  StickyColors.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//
//  Stickies' six colours, read from the app's own asset catalogue
//  (`Stickies<Name>Color`, the same in light and dark) on macOS 27. A note
//  stores its colour as components; it is named by the nearest of these,
//  within a small distance, else `.other`. Pure.
//

import Foundation

enum StickyColors {

    /// Each colour's sRGB components, as Stickies defines them.
    static let palette: [(StickyColor, Double, Double, Double)] = [
        (.yellow, 0.996078, 0.956863, 0.611765),
        (.blue, 0.678431, 0.956863, 1.0),
        (.green, 0.698039, 1.0, 0.631373),
        (.pink, 1.0, 0.780392, 0.780392),
        (.purple, 0.713725, 0.792157, 1.0),
        (.gray, 0.933333, 0.933333, 0.933333),
    ]

    /// The colour named by components, or `.other` past a few levels in each channel.
    static func name(red: Double, green: Double, blue: Double) -> StickyColor {
        let nearest = palette.min { distance($0, red, green, blue) < distance($1, red, green, blue) }
        guard let nearest, distance(nearest, red, green, blue) < 0.02 else { return .other }
        return nearest.0
    }

    /// `#RRGGBB`.
    static func hex(red: Double, green: Double, blue: Double) -> String {
        func byte(_ value: Double) -> Int { Int((min(max(value, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", byte(red), byte(green), byte(blue))
    }

    static func distance(_ entry: (StickyColor, Double, Double, Double), _ red: Double, _ green: Double, _ blue: Double) -> Double {
        max(abs(entry.1 - red), abs(entry.2 - green), abs(entry.3 - blue))
    }
}
