//
//  AppleStickiesError.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Why Stickies' notes could not be read.
public enum AppleStickiesError: Error, Sendable, Equatable, LocalizedError {
    /// There is no notes folder: Stickies has never been opened on this Mac.
    case folderNotFound(URL)
    /// macOS refused it: the app running this needs Full Disk Access.
    case permissionDenied(URL)
    /// No note matches.
    case noteNotFound(String)
    /// Stickies' "Make Sticky" service did not take the note.
    case serviceUnavailable
    /// The service took the note but no new note appeared on disk in time.
    case notSaved

    /// A sentence for a person.
    public var errorDescription: String? {
        switch self {
        case .folderNotFound: return "no Stickies notes on this Mac — open Stickies once"
        case .permissionDenied: return "macOS refused Stickies' notes — give the app running this Full Disk Access"
        case .noteNotFound(let note): return "no Stickies note \(note)"
        case .serviceUnavailable: return "Stickies' Make Sticky service did not answer — is Stickies on this Mac?"
        case .notSaved: return "Stickies took the note but did not save it in time — look for it on screen"
        }
    }
}
