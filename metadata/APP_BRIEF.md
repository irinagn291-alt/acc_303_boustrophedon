<!-- gf-brief source=bce77b798c64c4b70106cab6fbbd53587a115d41a6c846c0051fa57c44d8873c written=2026-09-26T02:03:58+03:00 -->
# Boustrophedon
## What it is
Boustrophedon is a quiet practice app for facing National Gallery painting captions. You save a painting, lay its maker or title as a line where every other word runs backward, then tap those words until they read forward. It is for anyone who wants a short, on-device word puzzle tied to real gallery works.

## Launch and onboarding
On a cold launch the system may show the notifications permission alert. After a short blank loading moment the native UI appears.

If welcome has not been finished, a full-screen welcome runs in three steps (page dots, no swipe required):

1. Title **"A line for captions."** Body **"Save a National Gallery painting, then lay its maker or title."** Button **"Next"**.
2. Title **"Face each backward word."** Body **"Every other word runs backward. Tap it to set the letters right."** Button **"Next"**.
3. Title **"Keep the faced line."** Body **"Misses stay so you can review them. All of it stays on this device."** Button **"Continue"** (finishes welcome and opens the home screen).

If welcome is already done, the home screen opens directly.

## Screens
### Face the words (home)
Title line **"Face the words"**. Toolbar icons **"Saved"** and **"Settings"** (open those sheets). Button **"Explore"** opens the Explore sheet.

When no painting is ready to work on: empty state **"Crate level."** / **"Save a work, then face."** with button **"Explore"**.

When a line is active:
- Large painting image (or a placeholder when none loads).
- Painting title (or **"Lay a caption"** if none), maker name, and a status line such as **"Idle"**, **"Turned"**, **"Faced"**, or **"Level"**, plus **"title line"** or **"maker line"**.
- Hint **"Tap a backward word."**, **"Lay a new line."**, or **"Save a work, then face."**
- Horizontal word chips. Each chip shows the word as displayed and a mark: **"Backward"**, **"Forward"**, or **"Miss"**. Tapping a backward word faces it; tapping a word that already reads forward records a miss.
- Feedback notes **"That word now reads forward."** or **"That word already reads forward."** (brief success mark on the painting when a face lands).
- Buttons **"Face"** (faces the next backward word), **"New line"** (lays a caption line for a saved painting that is not yet faced), **"Retract"** (undoes the newest face or yaw).
- **"Recently faced"** strip of faced paintings; tapping one opens Saved.
- Counts **"Faces filed"** and **"Yaws"**.

### Explore (sheet)
Navigation title **"Explore"**. Close control **"Close"**. Search prompt **"Maker or title"**.

- Empty search shows a local shelf of National Gallery paintings (title and maker per row). Tapping a row saves it to the crate and closes Explore (or keeps Explore open and marks **"Already here"** if that painting is already saved and focused).
- While a search runs: **"Looking"**.
- If search fails: **"Search did not finish."** with **"The gallery link paused."** or **"The reply could not be read."**, and **"Try again"**.
- If search stays empty after a query: **"Search stayed quiet."** / **"Try another word, or save from the shelf."** with **"Show shelf"**.
- If there is nothing to list at all: **"Crate is open."** / **"Save a painting so a line can start."** with **"Close"**.

### Saved (sheet)
Navigation title **"Saved"**. Close control **"Close"**.

Empty: **"Nothing faced yet."** / **"Lay a caption, then tap the backward words."** with **"Back to the line"**.

Otherwise:
- Section **"Faced"** — faced paintings with title and maker.
- Section **"Yaws"** — each miss as painting title (or **"Painting"**) and caption **"Word N on YYYYMMDD"**.
- Totals **"Faces"** and **"Yaws"**.

### Settings (sheet)
Navigation title **"Settings"**. Close control **"Close"**.

Section **"Sources"**:
- **"The National Gallery, London"** — opens the gallery site.
- **"Paintings"** — opens the gallery paintings page.
- **"Contact us"** — opens the support/contact page.

Section **"On this device"**:
- **"Retract"** — same undo as on home.
- **"Show the welcome again"** — returns the three-page welcome.

Destructive **"Reset all data"** opens **"Erase every painting and mark on this device?"** with **"Reset all data"** and **"Keep"**.

## Features
- Welcome walkthrough for captions, backward words, and on-device marks
- Explore National Gallery paintings by maker or title, with a local shelf when search is idle or fails
- Save paintings into a personal crate
- Lay a maker or title line with every other word letter-reversed
- Face backward words by tapping them or using **"Face"**
- Record yaws (misses) when a forward word is tapped
- **"New line"** to start the next unfinished painting
- **"Retract"** to undo the newest face or yaw
- **"Recently faced"** and Saved lists of faced works and yaws
- Face and yaw counts on home and Saved
- Settings links to National Gallery sources and contact
- Replay welcome; reset all on-device data
- Light appearance, portrait layout

## Behaviours that can look like bugs
- Welcome must be finished with **"Next"** / **"Continue"** before home is usable.
- Home shows **"Crate level."** until at least one painting is saved from Explore; use **"Explore"**, then tap a painting to save it.
- **"Face"** stays disabled until a line is **"Turned"** and at least one **"Backward"** word remains. Use **"New line"** first (or save a work so a line can start).
- **"New line"** stays disabled while the current painting is already **"Turned"**. Finish facing, or wait until the line is no longer turned.
- Word chips are disabled when the fold is not **"Turned"**.
- Tapping a **"Forward"** word does not face anything; it marks **"Miss"** and shows **"That word already reads forward."** Tap a **"Backward"** word instead.
- **"Retract"** stays disabled when both face and yaw counts are zero.
- Saving a painting that is already in the crate shows **"Already here"** and does not close Explore.
- After every turnable painting is faced, status can read **"Level"** and home can return to **"Crate level."** Save another work from Explore to continue.
- Search may show **"Looking"**, then **"Search did not finish."**; use **"Try again"** or clear the query / **"Show shelf"** to browse the shelf.
- **"Reset all data"** asks for confirmation; **"Keep"** cancels.

## Starter content and resume
Explore’s empty search shows a fixed local shelf of eight National Gallery works (for example **"The Arnolfini Portrait"** by Jan van Eyck, **"The Fighting Temeraire"** by Joseph Mallord William Turner, **"The Hay Wain"** by John Constable, **"The Ambassadors"** by Hans Holbein the Younger, **"Sunflowers"** by Vincent van Gogh, **"Bathers at Asnieres"** by Georges Seurat, **"Rain Steam and Speed"** by Joseph Mallord William Turner, **"Venus and Mars"** by Sandro Botticelli). They enter the crate only when the user saves them.

Saved paintings, live lines, faces, and yaws persist on this device and resume after relaunch. Unfinished turned lines can be continued; **"Retract"** can undo the newest mark.

## Permissions
Notifications — asked at cold launch via the system alert. No custom usage-description string is set for notifications.

The app does not ask for camera access. A camera usage string is present in the build settings: **"This app does not use the camera."**

## Absent
Login or accounts; in-app purchase; ads; analytics; user-generated content shared with others; account deletion flow; App Tracking Transparency prompt.

## Data and support
Painting saves, faces, and yaws stay on this device (welcome copy: **"All of it stays on this device."**). Support control: **"Contact us"** in Settings.

## Scanning and health
None.

## Platform
UI copy is English only (no localization files). Portrait only on iPhone and iPad; light appearance; requires full screen. Minimum iOS 17.0. Counts use the device’s number formatting; yaw dates use the device calendar as YYYYMMDD. No region lock beyond that.

## Category
Education
