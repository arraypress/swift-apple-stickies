//
//  Sticky.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One Stickies note.
public struct Sticky: Sendable, Codable, Equatable {
    /// Its identifier: the note's file name.
    public let id: String
    /// Its words.
    public let text: String
    /// Its words as Markdown: bold, italic, strikethrough, lists and links kept.
    public let markdown: String
    /// Its colour.
    public let color: StickyColor
    /// Its colour as `#RRGGBB`.
    public let hex: String?
    /// Where it sits on screen, in points from the bottom-left of the main display.
    public let frame: StickyFrame?
    /// Whether it floats on top of other windows.
    public let isFloating: Bool
    /// Whether it is translucent.
    public let isTranslucent: Bool
    /// Whether it is collapsed to its title bar.
    public let isCollapsed: Bool
    /// Its place in the stack: 1 is the front.
    public let order: Int?
    /// When it was last changed: its file's date.
    public let modified: Date?
    /// The pictures and files pasted into it.
    public let attachments: [URL]
    /// Where it is on disk: an `.rtfd` bundle.
    public let file: URL

    /// A note.
    public init(id: String, text: String, markdown: String, color: StickyColor, hex: String?, frame: StickyFrame?,
                isFloating: Bool, isTranslucent: Bool, isCollapsed: Bool, order: Int?, modified: Date?,
                attachments: [URL], file: URL) {
        self.id = id
        self.text = text
        self.markdown = markdown
        self.color = color
        self.hex = hex
        self.frame = frame
        self.isFloating = isFloating
        self.isTranslucent = isTranslucent
        self.isCollapsed = isCollapsed
        self.order = order
        self.modified = modified
        self.attachments = attachments
        self.file = file
    }

    /// Its first line, as a title.
    public var title: String {
        text.split(whereSeparator: \.isNewline).first.map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
    }
}
