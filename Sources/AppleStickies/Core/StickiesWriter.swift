//
//  StickiesWriter.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//
//  New notes, made by Stickies itself. Stickies has no AppleScript, but it
//  registers a system Service, "Make Sticky" (⇧⌘Y), that takes plain text,
//  RTF or RTFD. Text is put on a private pasteboard and handed to it with
//  `NSPerformService`; Stickies opens (if it was not running), shows the
//  note and saves it — on the Mac it was on disk within 0.5 s. Its files are
//  never written here. A note cannot be edited or deleted this way, and its
//  colour is Stickies' own choice.
//

import AppKit
import Foundation

/// Makes Stickies notes through Stickies' own service.
///
/// ```swift
/// let note = try StickiesWriter.add("Buy oat milk")
/// let styled = try StickiesWriter.add(markdown: "**Call** the plumber")
/// ```
public enum StickiesWriter {

    /// The service Stickies registers.
    public static let serviceName = "Make Sticky"

    /// Makes a note of plain text, and returns it once Stickies has saved it.
    ///
    /// - Throws: ``AppleStickiesError/serviceUnavailable`` or ``AppleStickiesError/notSaved``.
    @discardableResult
    public static func add(_ text: String, folder: URL = StickiesStore.defaultLocation, wait: Double = 5) throws -> Sticky {
        try make(StickyPasteboard.items(text: text, rtf: nil), folder: folder, wait: wait)
    }

    /// Makes a note from Markdown — bold, italic, strikethrough and links kept
    /// as Stickies' own styles — and returns it once Stickies has saved it.
    ///
    /// - Throws: ``AppleStickiesError/serviceUnavailable`` or ``AppleStickiesError/notSaved``.
    @discardableResult
    public static func add(markdown: String, folder: URL = StickiesStore.defaultLocation, wait: Double = 5) throws -> Sticky {
        try make(StickyPasteboard.items(text: markdown, rtf: StickyPasteboard.rtf(markdown: markdown)), folder: folder, wait: wait)
    }

    private static func make(_ items: [(NSPasteboard.PasteboardType, Data)], folder: URL, wait: Double) throws -> Sticky {
        let before = StickyPasteboard.noteFiles(in: folder)
        let board = NSPasteboard(name: NSPasteboard.Name("stickies-\(UUID().uuidString)"))
        defer { board.releaseGlobally() }
        board.clearContents()
        for (type, data) in items { board.setData(data, forType: type) }
        guard NSPerformService(serviceName, board) else { throw AppleStickiesError.serviceUnavailable }
        let deadline = Date().addingTimeInterval(wait)
        repeat {
            Thread.sleep(forTimeInterval: 0.2)
            if let id = StickyPasteboard.newNote(before: before, after: StickyPasteboard.noteFiles(in: folder)),
               let note = try? StickiesStore(folder: folder).note(id) {
                return note
            }
        } while Date() < deadline
        throw AppleStickiesError.notSaved
    }
}
