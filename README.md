# Swift Apple Stickies

Read Apple's Stickies from Swift — every note's words (as text and Markdown), its colour,
its place on screen, and whether it floats, is translucent or collapsed — from Stickies'
own files, not by driving the app.

```swift
import AppleStickies

let store = try StickiesStore()
for note in store.notes() { print(note.color, note.title, note.isFloating) }
print(try store.note("1F2E").markdown)     // the start of an id is enough
store.search("milk")

let note = try StickiesWriter.add("Buy oat milk")              // made by Stickies itself
try StickiesWriter.add(markdown: "**Call** the _plumber_")      // bold and italic kept
```

## Where Stickies keeps its notes

Measured on macOS 27 (Stickies 10.3):

- **Each note is an RTFD bundle**, `<UUID>.rtfd` (its text in `TXT.rtf`, pasted pictures
  beside it), in `~/Library/Containers/com.apple.Stickies/Data/Library/Stickies/`. The
  container is protected: the app reading it needs Full Disk Access. Read through
  [swift-rich-text](https://github.com/arraypress/swift-rich-text).
- **How each note looks** is in `.SavedStickiesState` beside them, an XML property list:
  `UUID`, `StickyColor` (components), `Frame` (`{{x, y}, {w, h}}`, points from the bottom-left
  of the main display), `ExpandedSize` (a collapsed note's frame is shorter), `Floating`,
  `Translucent`, `ZOrder` (1 is the front).
- **Colours** are named by Stickies' own: the six `Stickies<Name>Color` entries in the app's
  asset catalogue (the same in light and dark) — yellow `#FEF49C`, blue `#ADF4FF`, green
  `#B2FFA1`, pink `#FFC7C7`, purple `#B6CAFF`, gray `#EEEEEE`. A note's stored yellow matched
  the catalogue's exactly. Anything else is `.other`, with its hex.
- **Dates**: Stickies keeps none; a note's is its text file's.

## Writing

Stickies has no AppleScript dictionary, but it registers a system Service, **Make Sticky**
(⇧⌘Y), that takes plain text, RTF or RTFD. `StickiesWriter` puts the words on a private
pasteboard and hands them to it with `NSPerformService`: Stickies opens if it was not
running, shows the note and saves it (on disk within 0.5 s, measured), and the new note —
the one bundle that was not there before — is returned. Stickies' files are never written
here. Markdown is turned into RTF first (bold, italic, strikethrough, links). A note
cannot be edited or deleted this way, and its colour is Stickies' choice.

## Tested

6 tests on a synthetic folder of notes with a state file using the real keys — no one's notes
are read. Every rule broken on purpose is caught (15 of 16 mutations; the one left asks for
`inlineOnlyPreservingWhitespace`, which parsed exactly like `inlineOnly` on macOS 27).
Checked by hand: two test notes read; a plain and a Markdown note made through the service
and read back with their styles.

## Requirements

macOS 14 or later; Swift 6.2. Full Disk Access for the app reading it.

## License

MIT — see [LICENSE](LICENSE).
