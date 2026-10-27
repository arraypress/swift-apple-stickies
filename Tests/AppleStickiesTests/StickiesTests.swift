//
//  StickiesTests.swift
//  AppleStickies
//
//  Created by David Sherlock on 2026.
//
//  Stickies with no Stickies: a folder of RTFD notes and a state file with
//  the real keys. Every note is invented.
//

import AppKit
import Foundation
import XCTest
@testable import AppleStickies

final class StickiesTests: XCTestCase {

    var folder: URL!

    override func setUpWithError() throws {
        folder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("stickies-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    override func tearDown() { try? FileManager.default.removeItem(at: folder) }

    let shopping = "11111111-1111-4111-8111-111111111111"
    let ideas = "22222222-2222-4222-8222-222222222222"
    let loose = "33333333-3333-4333-8333-333333333333"

    func note(_ id: String, _ text: NSAttributedString, modified: Date) throws {
        let bundle = try text.fileWrapper(from: NSRange(location: 0, length: text.length),
                                          documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
        let url = folder.appendingPathComponent("\(id).rtfd")
        try bundle.write(to: url, options: .atomic, originalContentsURL: nil)
        try FileManager.default.setAttributes([.modificationDate: modified], ofItemAtPath: url.appendingPathComponent("TXT.rtf").path)
    }

    func entry(_ id: String, red: Double, green: Double, blue: Double, frame: String, expanded: String, z: Int, floating: Bool = false) -> [String: Any] {
        ["UUID": id, "StickyColor": ["Red": red, "Green": green, "Blue": blue, "Alpha": 1.0], "Frame": frame, "ExpandedSize": expanded,
         "Floating": floating, "Translucent": false, "ZOrder": z, "ExpandFrameY": 0.0]
    }

    func makeStore() throws -> StickiesStore {
        let body = NSFont.systemFont(ofSize: 12)
        let list = NSMutableAttributedString(string: "Shopping\n", attributes: [.font: NSFontManager.shared.convert(body, toHaveTrait: .boldFontMask)])
        list.append(NSAttributedString(string: "Oat milk and bread", attributes: [.font: body]))
        try note(shopping, list, modified: Date(timeIntervalSince1970: 1_700_000_000))
        try note(ideas, NSAttributedString(string: "Paint the fence blue", attributes: [.font: body]), modified: Date(timeIntervalSince1970: 1_700_000_100))
        try note(loose, NSAttributedString(string: "Café list", attributes: [.font: body]), modified: Date(timeIntervalSince1970: 1_700_000_200))
        let state: [[String: Any]] = [
            entry(ideas, red: 0.678431, green: 0.956863, blue: 1.0, frame: "{{100, 200}, {300, 22}}", expanded: "{300, 200}", z: 1, floating: true),
            entry(shopping, red: 0.996078, green: 0.956863, blue: 0.611765, frame: "{{695, 1020}, {300, 200}}", expanded: "{300, 200}", z: 2),
        ]
        try PropertyListSerialization.data(fromPropertyList: state, format: .xml, options: 0)
            .write(to: folder.appendingPathComponent(".SavedStickiesState"))
        return try StickiesStore(folder: folder)
    }

    func testNotesAreReadWithHowTheyLook() throws {
        let notes = try makeStore().notes()
        XCTAssertEqual(notes.map(\.id), [ideas, shopping, loose], "front of the stack first; an unplaced note after")
        let shoppingNote = try XCTUnwrap(notes.first { $0.id == shopping })
        XCTAssertEqual(shoppingNote.text, "Shopping\nOat milk and bread")
        XCTAssertEqual(shoppingNote.markdown, "**Shopping**\nOat milk and bread")
        XCTAssertEqual(shoppingNote.title, "Shopping")
        XCTAssertEqual(shoppingNote.color, .yellow)
        XCTAssertEqual(shoppingNote.hex, "#FEF49C")
        XCTAssertEqual(shoppingNote.frame, StickyFrame(x: 695, y: 1020, width: 300, height: 200))
        XCTAssertFalse(shoppingNote.isCollapsed)
        XCTAssertEqual(shoppingNote.modified, Date(timeIntervalSince1970: 1_700_000_000))
        let ideasNote = try XCTUnwrap(notes.first { $0.id == ideas })
        XCTAssertEqual(ideasNote.color, .blue)
        XCTAssertTrue(ideasNote.isFloating)
        XCTAssertTrue(ideasNote.isCollapsed, "shorter than its expanded size")
        XCTAssertEqual(notes.last?.color, .yellow, "a note the state does not know is Stickies' default")
        XCTAssertNil(notes.last?.order)
    }

    func testColoursAreNamedOnlyWhenTheyAreStickiesOwn() {
        for (color, red, green, blue) in StickyColors.palette {
            XCTAssertEqual(StickyColors.name(red: red, green: green, blue: blue), color)
        }
        XCTAssertEqual(StickyColors.name(red: 0.5, green: 0.2, blue: 0.1), .other)
        XCTAssertEqual(StickyColors.name(red: 0.996, green: 0.2, blue: 0.2), .other, "every channel must match, not just red")
        XCTAssertEqual(StickyColors.hex(red: 1, green: 0, blue: 0.5), "#FF0080")
        XCTAssertNil(StickiesState.frame("{1, 2}"))
        XCTAssertEqual(StickiesState.entries(Data("not a plist".utf8)), [:])
    }

    func testNotesAreFoundByIdAndWords() throws {
        let store = try makeStore()
        XCTAssertEqual(try store.note("2222").id, ideas, "the start of an id is enough")
        XCTAssertThrowsError(try store.note("22"), "too short to be sure")
        XCTAssertThrowsError(try store.note("9999"))
        XCTAssertEqual(store.search("OAT MILK").map(\.id), [shopping], "case ignored")
        XCTAssertEqual(store.search("cafe").map(\.id), [loose], "accents ignored")
        XCTAssertEqual(store.search(" ").count, 0)
    }

    func testAMissingFolderSaysSo() {
        let missing = folder.appendingPathComponent("none")
        XCTAssertThrowsError(try StickiesStore(folder: missing)) { XCTAssertEqual($0 as? AppleStickiesError, .folderNotFound(missing)) }
    }
}
