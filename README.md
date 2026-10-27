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

Nothing here writes. Stickies has no AppleScript dictionary; it does register a system
Service, **Make Sticky** (⇧⌘Y), which makes a new note from text through the app itself.

## Tested

4 tests on a synthetic folder of notes with a state file using the real keys — no one's notes
are read. Every rule broken on purpose is caught (9 of 9 mutations). Checked by hand on two
test notes: words, emphasis, colour and order all read.

## Requirements

macOS 14 or later; Swift 6.2. Full Disk Access for the app reading it.

## License

MIT — see [LICENSE](LICENSE).
