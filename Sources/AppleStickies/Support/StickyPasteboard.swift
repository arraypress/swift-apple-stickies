//
//  StickyPasteboard.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//
//  What is handed to Stickies' service, and how the note it makes is
//  found: the one `.rtfd` in the folder that was not there before. Pure.
//

import AppKit
import Foundation

enum StickyPasteboard {

    /// The pasteboard items for a note: RTF first when there is styling, plain text always.
    static func items(text: String, rtf: Data?) -> [(NSPasteboard.PasteboardType, Data)] {
        var items: [(NSPasteboard.PasteboardType, Data)] = []
        if let rtf { items.append((.rtf, rtf)) }
        items.append((.string, Data(text.utf8)))
        return items
    }

    /// Markdown as RTF — inline styles only, line breaks kept — or nil when it does not parse.
    static func rtf(markdown: String) -> Data? {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        guard let parsed = try? AttributedString(markdown: markdown, options: options) else { return nil }
        let text = NSMutableAttributedString(parsed)
        let whole = NSRange(location: 0, length: text.length)
        let body = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        text.addAttribute(.font, value: body, range: whole)
        text.enumerateAttribute(.inlinePresentationIntent, in: whole) { value, range, _ in
            guard let raw = value as? UInt else { return }
            let intent = InlinePresentationIntent(rawValue: raw)
            var traits: NSFontTraitMask = []
            if intent.contains(.stronglyEmphasized) { traits.insert(.boldFontMask) }
            if intent.contains(.emphasized) { traits.insert(.italicFontMask) }
            if !traits.isEmpty { text.addAttribute(.font, value: NSFontManager.shared.convert(body, toHaveTrait: traits), range: range) }
            if intent.contains(.strikethrough) { text.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range) }
        }
        return try? text.data(from: whole, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }

    /// The note files in a folder.
    static func noteFiles(in folder: URL) -> Set<String> {
        Set(((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []).filter { $0.hasSuffix(".rtfd") })
    }

    /// The id of the one note that appeared, or nil while there is none (or more than one).
    static func newNote(before: Set<String>, after: Set<String>) -> String? {
        let added = after.subtracting(before)
        guard added.count == 1, let file = added.first else { return nil }
        return String(file.dropLast(".rtfd".count))
    }
}
