# Architecture Decision: editor launch and remote save

📌 CREATIVE PHASE START: text editor launch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 1. Problem

The preferred editor must open both local and remote files. `openLocalFileInEditor:` already opens a local file with `NSWorkspace` and no ODB parameters. `ODBEditFile:` downloads a remote file into `/private/tmp/Fugu`, then sends an ODB open event. `handleODBFileModifiedEvent:` pushes that temp file onto `uploadQueue`. `handleODBFileClosedEvent:` removes the edited-document entry. Quit deletes `/private/tmp/Fugu`.

Visual Studio Code, Cursor, Sublime Text, and Zed do not send `kAEModifiedFile` or `kAEClosedFile`. Opening one of them with only `NSWorkspace` leaves the save in a temp file that quit removes.

Requirements:

- The user's chosen installed editor opens the file.
- An editor that already speaks ODB keeps the current upload and close behavior.
- A remote save from an editor that does not speak ODB still reaches the server.
- No new package. `SFTPPrefs` stays Objective-C.

## 2. Options

- Option A: Watch the temp file's directory and upload when the file settles. Keep the ODB path for editors that speak it.
- Option B: Open the non-ODB editor and leave the upload to the user.
- Option C: Use a non-ODB editor for local files only. Remote edit stays on an ODB editor.

## 3. Analysis

| Criterion | A directory watch | B open only | C local only |
| --- | --- | --- | --- |
| Preferred editor opens a remote file | Yes | Yes | No |
| Remote save returns to the server | After the file settles | No | Only for an ODB editor |
| Data left in `/private/tmp/Fugu` | Uploaded while connected | Deleted on quit | Unchanged for ODB |
| Risk | A partial write can upload if the debounce is wrong | Silent loss on quit | The menu choice does not apply to remote edit |
| New code | One watch per edited temp directory | An alert, then the existing open | A second editor choice for remote files |

Option B conflicts with quit. `applicationWillTerminate:` removes `/private/tmp/Fugu` with no save. The user would not see that file in the local pane. Option C keeps today's remote path, and it drops the reason to pick Cursor or Visual Studio Code in an SFTP client.

## 4. Decision

Selected: Option A.

Rationale: The menu stores one preferred editor. That editor opens local and remote files. Editors marked as ODB keep the Apple event, so BBEdit, TextMate, CotEditor, and the other current ODB apps do not gain a second upload path. `vi` and `emacs` keep `UMFileLauncher`. Every other installed editor opens through `NSWorkspace` with a nil ODB event, and a directory watch uploads the temp file.

## 5. Implementation notes

- The catalog record carries `supportsODB`. ODB and CLI records do not get a watch.
- Start the watch only after the download has been opened. The baseline is the file's modification time and size at that moment.
- Watch the temp directory, not the file inode. These editors replace the file by rename. Match the edited file's last path component.
- Use one `DispatchSource` file-system source per edited temp directory. Debounce 500 ms. Upload only when the size is the same on two checks inside that window, and the modification time is newer than the last upload.
- Skip a transient zero-byte size when the last uploaded size was non-zero. If the next check is still zero, upload it.
- The upload dictionary matches `handleODBFileModifiedEvent:`: `isdir` 0, `fullpath` the local temp path, `pathfrombase` the remote path. Then `writeCommand:` with a space.
- Stop the watch in `removeFromEditedDocuments:`, when disconnect clears `editedDocuments`, and in `applicationWillTerminate:` before the temp directory is removed. Do not upload during termination. The disconnect alert already says unsaved changes are lost.
- `PostEditBehaviour` still activates Fugu only from the ODB close event. A non-ODB editor has no close event, so Fugu does not steal focus back.
- Do not watch a local file.

## 6. Validation

- An ODB editor still uploads a remote save once, and closing it still removes the edited-document entry.
- Visual Studio Code, Cursor, Sublime Text, or Zed, whichever is installed, opens a remote file and a later save uploads once after the debounce.
- Quit with that editor still open does not add a new upload. Disconnect still shows the existing edited-document warning.
- A local file opens in the chosen editor and does not enter `editedDocuments`.
