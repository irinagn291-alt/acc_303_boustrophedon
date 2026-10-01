<!-- gf-brief source=aa75eb8a240216c3b2cf1e9fb34f6a9337a3f01f97772432911ed1f97790c317 written=2026-09-30T16:10:41+03:00 -->
# Boustrophedon
## What it is
Boustrophedon is a short practice app for facing National Gallery painting captions. You save a painting, lay its maker or title as a line where every other word runs backward, then tap those words until they read forward. It is for anyone who wants an on-device word puzzle tied to real gallery works.

## Launch and onboarding
On a cold launch the screen can sit blank for a short moment. The system may show the notifications permission alert. There is no in-app permission screen and no custom notifications usage string.

If welcome has not been finished, a full-screen welcome runs in three steps. Page dots are visible but not tappable. There is no skip and no swipe; only the bottom button advances.

1. Title **"A line for captions."** Body **"Save a National Gallery painting, then lay its maker or title."** Button **"Next"**.
2. Title **"Face each backward word."** Body **"Every other word runs backward. Tap it to set the letters right."** Button **"Next"**.
3. Title **"Keep the faced line."** Body **"Misses stay so you can review them. All of it stays on this device."** Button **"Continue"** (finishes welcome and opens home).

If welcome is already done, home opens directly.

## Screens
### Face the words (home)
Title **"Face the words"**. There is no tab bar. Toolbar icons **"Saved"** and **"Settings"** open those sheets. Button **"Explore"** opens the Explore sheet.

When no saved painting is ready to work on: full-page empty state **"Crate level."** / **"Save a work, then face."** with button **"Explore"**.

When a line is active:
- A large painting image (placeholder art if the picture does not load). VoiceOver on the image is **"title, maker"**, or **"Painting"** if none.
- Painting title, or **"Lay a caption"** if none.
- Maker name under the title.
- Status line built as **"Idle"**, **"Turned"**, **"Faced"**, or **"Level"**, then a comma, then **"title line"** or **"maker line"** (for example **"Turned, maker line"**).
- Hint **"Tap a backward word."**, **"Lay a new line."**, or **"Save a work, then face."**
- A horizontal row of word chips. Each chip shows the word as displayed and a mark: **"Backward"**, **"Forward"**, or **"Miss"**. VoiceOver on a chip is that mark plus the true catalog word. Tapping a **"Backward"** word faces it. Tapping a **"Forward"** word records a miss. Chips do nothing while the line is not **"Turned"**.
- Feedback **"That word now reads forward."** or **"That word already reads forward."** A brief success mark can appear on the painting when a face lands.
- **"Face"** faces the next remaining **"Backward"** word (same result as tapping that chip).
- **"New line"** lays a caption line for the first saved painting that is not yet faced.
- **"Retract"** undoes the newest face or yaw.
- **"Recently faced"** appears after at least one painting is faced. Each tile shows the painting title; tapping it opens Saved. VoiceOver is **"title, faced"**.
- Counts **"Faces filed"** and **"Yaws"** (numbers follow the device’s decimal format).

After the first save from Explore, home can show that painting’s line without tapping **"New line"**.

### Explore (sheet)
Navigation title **"Explore"**. Close control **"Close"** (X). Search field prompt **"Maker or title"**.

- An empty search shows a local shelf of National Gallery paintings. Each row is title and maker. Tapping a row saves it and closes Explore. If that painting is already saved and is the focused one, the row stays open, may scroll to it, and can show **"Already here"**.
- While a typed search runs: **"Looking"**.
- If search fails and rows are still shown: **"Search did not finish."** with **"The gallery link paused."** or **"The reply could not be read."**, and **"Try again"**.
- If a typed search ends with no rows: **"Search stayed quiet."** / **"Try another word, or save from the shelf."** with **"Show shelf"** (clears the query and shows the shelf).
- If there is nothing to list at all: **"Crate is open."** / **"Save a painting so a line can start."** with **"Close"**.

### Saved (sheet)
Navigation title **"Saved"**. Close control **"Close"** (X).

Empty when nothing has been faced and there are no yaws: **"Nothing faced yet."** / **"Lay a caption, then tap the backward words."** with **"Back to the line"** (returns to home).

Otherwise:
- Section **"Faced"** — faced paintings with title and maker. Rows are not tappable.
- Section **"Yaws"** — each miss shows the painting title, or **"Painting"** if the work is gone, and **"Word N on YYYYMMDD"** (N is 1-based; the date is the device calendar as year-month-day with no separators).
- Totals **"Faces"** and **"Yaws"**.

### Settings (sheet)
Navigation title **"Settings"**. Close control **"Close"** (X).

Section **"Sources"**:
- **"The National Gallery, London"** — opens the gallery site.
- **"Paintings"** — opens the gallery paintings page.
- **"Contact us"** — opens the support page.

Section **"On this device"**:
- **"Retract"** — same undo as on home (not disabled here even when counts are zero).
- **"Show the welcome again"** — returns the three-page welcome. Saved paintings and marks stay.

Destructive **"Reset all data"** opens **"Erase every painting and mark on this device?"** with **"Reset all data"** (clears the crate and returns welcome) and **"Keep"** (cancels).

### Shortcuts (system)
If the person opens Shortcuts, these titles exist: **"Turn furrow"**, **"Face stichos"**, **"Open quiz"**, **"Open explore"**, **"Open saved"**, **"Open settings"**. They are not on-screen buttons inside the app.

## Features
- Welcome for captions, backward words, and on-device marks
- Explore National Gallery paintings by **"Maker or title"**, with a local shelf when search is idle or fails
- Save a painting into the crate
- Lay a **"maker line"** or **"title line"** with every other word letter-reversed
- Face backward words by tapping a chip or **"Face"**
- Record a yaw (**"Miss"**) when a **"Forward"** word is tapped
- **"New line"** to start the next unfinished painting
- **"Retract"** to undo the newest face or yaw
- **"Recently faced"** and Saved lists of faced works and yaws
- **"Faces filed"** / **"Faces"** and **"Yaws"** counts
- Settings links to National Gallery sources and **"Contact us"**
- **"Show the welcome again"** and **"Reset all data"**
- Light appearance, portrait layout

## Behaviours that can look like bugs
- Welcome cannot be dismissed except by finishing **"Next"** / **"Next"** / **"Continue"**.
- Home shows **"Crate level."** until at least one painting is saved. Use **"Explore"**, then tap a shelf row.
- A painting can start a line only if its chosen maker or title has at least two words. The eight shelf works all can.
- **"Face"** stays disabled until the status is **"Turned"** and at least one **"Backward"** word remains. After the first save a line is usually already turned; otherwise use **"New line"**.
- **"New line"** stays disabled while the current painting is already **"Turned"**. Face the remaining backward words, or save another work after the current one is faced.
- Word chips do nothing when the line is not **"Turned"**.
- Tapping a **"Forward"** word does not face it. It marks **"Miss"**, adds a yaw, and shows **"That word already reads forward."** Tap a **"Backward"** word, or **"Face"**.
- **"Retract"** on home stays disabled while both face and yaw counts are zero.
- Saving a painting that is already in the crate can show **"Already here"** and leaves Explore open.
- After every turnable saved painting is faced, status can read **"Level"** and home can return to **"Crate level."** Save another work from Explore to continue.
- Search may show **"Looking"**, then **"Search did not finish."** Use **"Try again"**, clear the query, or **"Show shelf"**.
- **"Crate is open."** is a last-resort empty Explore. The usual empty search is the shelf, not this page.
- **"Reset all data"** asks **"Erase every painting and mark on this device?"** **"Keep"** cancels. Confirming also brings welcome back.
- A short blank wait, or the system notifications alert, can appear before welcome or home.

## Starter content and resume
Explore’s empty search shows a fixed local shelf of eight National Gallery works. They enter the crate only when the person saves them:

- **"The Arnolfini Portrait"** by **"Jan van Eyck"** — first save lays a **"maker line"**: **"Jan"** (**"Forward"**), **"nav"** (**"Backward"**), **"Eyck"** (**"Forward"**).
- **"The Fighting Temeraire"** by **"Joseph Mallord William Turner"** — **"maker line"**: **"Joseph"** (**"Forward"**), **"drollaM"** (**"Backward"**), **"William"** (**"Forward"**), **"renruT"** (**"Backward"**).
- **"The Hay Wain"** by **"John Constable"** — **"maker line"**: **"John"** (**"Forward"**), **"elbatsnoC"** (**"Backward"**).
- **"The Ambassadors"** by **"Hans Holbein the Younger"** — **"maker line"**: **"Hans"** (**"Forward"**), **"niebloH"** (**"Backward"**), **"the"** (**"Forward"**), **"regnuoY"** (**"Backward"**).
- **"Sunflowers"** by **"Vincent van Gogh"** — **"maker line"** (the title is one word): **"Vincent"** (**"Forward"**), **"nav"** (**"Backward"**), **"Gogh"** (**"Forward"**).
- **"Bathers at Asnieres"** by **"Georges Seurat"** — **"title line"**: **"Bathers"** (**"Forward"**), **"ta"** (**"Backward"**), **"Asnieres"** (**"Forward"**).
- **"Rain Steam and Speed"** by **"Joseph Mallord William Turner"** — **"title line"**: **"Rain"** (**"Forward"**), **"maetS"** (**"Backward"**), **"and"** (**"Forward"**), **"deepS"** (**"Backward"**).
- **"Venus and Mars"** by **"Sandro Botticelli"** — **"maker line"**: **"Sandro"** (**"Forward"**), **"illecittoB"** (**"Backward"**).

Saved paintings, the live line, faces, and yaws persist on this device and resume after relaunch. An unfinished **"Turned"** line can be continued. **"Retract"** undoes only the newest mark.

On a device, the crate is not pre-filled. A first Simulator launch may already have those eight works, some faces and yaws, a live line, and welcome already finished.

## Permissions
Notifications — asked at cold launch via the system alert. No custom usage-description string is set for notifications.

The app does not ask for camera access. A camera usage string is present in the build settings: **"This app does not use the camera."**

## Absent
Login or accounts; in-app purchase; ads; user-generated content shared with others; account deletion flow; App Tracking Transparency prompt.

## Data and support
Painting saves, faces, and yaws stay on this device (welcome copy: **"All of it stays on this device."**). Explore can look up further National Gallery paintings when a search is typed; if that lookup pauses, the local shelf still works. Support control: **"Contact us"** in Settings.

## Scanning and health
None.

## Platform
UI copy is English only. Portrait only on iPhone and iPad; light appearance; requires full screen. Minimum iOS 17.0. Counts use the device’s number formatting. Yaw dates use the device calendar as YYYYMMDD. No region lock beyond that.

## Category
Education
