//
//  StickyFrame.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Where a note sits on screen, in points.
public struct StickyFrame: Sendable, Codable, Equatable {
    /// From the left of the main display.
    public let x: Double
    /// From the bottom of the main display.
    public let y: Double
    /// Its width.
    public let width: Double
    /// Its height.
    public let height: Double

    /// A frame.
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
