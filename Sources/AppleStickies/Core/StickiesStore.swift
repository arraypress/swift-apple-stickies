//
//  StickiesStore.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//
//  Stickies' notes, read from their files — not by driving the app. Each
//  note is an RTFD bundle, `<UUID>.rtfd`, in Stickies' sandbox container;
//  how each one looks (colour, place, floating, translucent, collapsed,
//  stacking) is in `.SavedStickiesState` beside them (StickiesState). The
//  words are read through swift-rich-text. Nothing is written.
//

import Foundation
import RichText

/// Stickies' notes, read-only.
///
/// ```swift
/// let store = try StickiesStore()
/// for note in store.notes() { print(note.color, note.title) }
/// store.search("milk")
/// ```
public struct StickiesStore: Sendable {

    /// Where Stickies keeps its notes.
    public static var defaultLocation: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Containers/com.apple.Stickies/Data/Library/Stickies")
    }

    /// The notes folder.
    public let folder: URL

    /// Opens the notes folder.
    ///
    /// - Parameter folder: The folder; the live one by default.
    /// - Throws: ``AppleStickiesError/folderNotFound(_:)`` or ``AppleStickiesError/permissionDenied(_:)``.
    public init(folder: URL = StickiesStore.defaultLocation) throws {
        var isFolder: ObjCBool = false
        guard FileManager.default.fileExists(atPath: folder.path, isDirectory: &isFolder), isFolder.boolValue else {
            throw AppleStickiesError.folderNotFound(folder)
        }
        guard (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) != nil else {
            throw AppleStickiesError.permissionDenied(folder)
        }
        self.folder = folder
    }

    /// Every note, front of the stack first (then the newest).
    public func notes() -> [Sticky] {
        let state = StickiesState.entries(try? Data(contentsOf: folder.appendingPathComponent(".SavedStickiesState")))
        let bundles = ((try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.contentModificationDateKey])) ?? [])
            .filter { $0.pathExtension == "rtfd" }
        return bundles.compactMap { bundle -> Sticky? in
            guard let text = try? RichText.attributed(rtfd: bundle) else { return nil }
            let id = bundle.deletingPathExtension().lastPathComponent
            let entry = state[id] ?? StickiesState.Entry()
            let modified = [bundle.appendingPathComponent("TXT.rtf"), bundle].lazy
                .compactMap { try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate }.first
            return Sticky(id: id, text: RichText.plain(text), markdown: RichText.markdown(text), color: entry.color, hex: entry.hex,
                          frame: entry.frame, isFloating: entry.isFloating, isTranslucent: entry.isTranslucent,
                          isCollapsed: entry.isCollapsed, order: entry.order, modified: modified,
                          attachments: RichText.attachments(rtfd: bundle), file: bundle)
        }.sorted(by: Self.stacking)
    }

    /// A note by its id, or the start of it (at least four characters).
    public func note(_ id: String) throws -> Sticky {
        let all = notes()
        if let exact = all.first(where: { $0.id.caseInsensitiveCompare(id) == .orderedSame }) { return exact }
        let matches = id.count >= 4 ? all.filter { $0.id.lowercased().hasPrefix(id.lowercased()) } : []
        guard matches.count == 1, let only = matches.first else { throw AppleStickiesError.noteNotFound(id) }
        return only
    }

    /// Notes whose words hold `text`, ignoring case and accents.
    public func search(_ text: String) -> [Sticky] {
        let needle = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return [] }
        return notes().filter { $0.text.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    /// Front of the stack first; notes the state does not place, newest first, after.
    static func stacking(_ a: Sticky, _ b: Sticky) -> Bool {
        switch (a.order, b.order) {
        case let (x?, y?) where x != y: return x < y
        case (_?, nil): return true
        case (nil, _?): return false
        default: return (a.modified ?? .distantPast) > (b.modified ?? .distantPast)
        }
    }
}
