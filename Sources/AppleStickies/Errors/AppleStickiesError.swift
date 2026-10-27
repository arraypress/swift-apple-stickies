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

    /// A sentence for a person.
    public var errorDescription: String? {
        switch self {
        case .folderNotFound: return "no Stickies notes on this Mac — open Stickies once"
        case .permissionDenied: return "macOS refused Stickies' notes — give the app running this Full Disk Access"
        case .noteNotFound(let note): return "no Stickies note \(note)"
        }
    }
}
