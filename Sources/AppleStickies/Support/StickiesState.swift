//
//  StickiesState.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//
//  `.SavedStickiesState`: an XML property list beside the notes, one
//  dictionary per open note — `UUID`, `StickyColor` (Red/Green/Blue/Alpha),
//  `Frame` ("{{x, y}, {w, h}}"), `ExpandedSize`, `Floating`, `Translucent`,
//  `ZOrder`. A collapsed note's frame is shorter than its expanded size.
//  Pure.
//

import Foundation

enum StickiesState {

    /// What the state file says about one note.
    struct Entry: Equatable {
        var color: StickyColor = .yellow
        var hex: String?
        var frame: StickyFrame?
        var isFloating = false
        var isTranslucent = false
        var isCollapsed = false
        var order: Int?
    }

    /// Each note's entry, by id.
    static func entries(_ data: Data?) -> [String: Entry] {
        guard let data, let list = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [[String: Any]] else { return [:] }
        var found: [String: Entry] = [:]
        for item in list {
            guard let id = item["UUID"] as? String else { continue }
            var entry = Entry()
            if let color = item["StickyColor"] as? [String: Any], let red = number(color["Red"]), let green = number(color["Green"]),
               let blue = number(color["Blue"]) {
                entry.color = StickyColors.name(red: red, green: green, blue: blue)
                entry.hex = StickyColors.hex(red: red, green: green, blue: blue)
            }
            entry.frame = (item["Frame"] as? String).flatMap(frame)
            entry.isFloating = item["Floating"] as? Bool ?? false
            entry.isTranslucent = item["Translucent"] as? Bool ?? false
            entry.order = (item["ZOrder"] as? NSNumber)?.intValue
            if let expanded = (item["ExpandedSize"] as? String).flatMap(size), let height = entry.frame?.height {
                entry.isCollapsed = height + 1 < expanded.height
            }
            found[id] = entry
        }
        return found
    }

    /// `{{x, y}, {w, h}}` as a frame.
    static func frame(_ text: String) -> StickyFrame? {
        let numbers = values(text)
        guard numbers.count == 4 else { return nil }
        return StickyFrame(x: numbers[0], y: numbers[1], width: numbers[2], height: numbers[3])
    }

    /// `{w, h}` as a size.
    static func size(_ text: String) -> (width: Double, height: Double)? {
        let numbers = values(text)
        return numbers.count == 2 ? (numbers[0], numbers[1]) : nil
    }

    static func values(_ text: String) -> [Double] {
        text.split { "{}, ".contains($0) }.compactMap { Double($0) }
    }

    static func number(_ value: Any?) -> Double? { (value as? NSNumber)?.doubleValue }
}
