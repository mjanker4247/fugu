# Active Context

## Current Focus

Step 5a browser views, on `migrate/step-05a-browser-views`. The classes are Swift. Browser smoke is still open.

## Status

`SFTPSplitView`, `SFTPScrollView`, `SFTPTableView`, `SFTPItemCell`, `SFTPImageView`, and `SFTPImagePreviewPanel` are Swift. `MainMenu.xib` sets `customModule="Fugu"` on those classes. `SFTPTableViewDrag.m` keeps `dragImage:at:offset:event:pasteboard:source:slideBack:`, `draggingSourceOperationMaskForLocal:`, and `draggedImage:endedAt:operation:` because Swift marks those selectors unavailable. Development `xcodebuild` succeeded on 8 Nov 2026. Preferences, SCP, the tunnel, and `SFTPController` stay Objective-C.

## Next action

Smoke this branch on the Mac: open both panes, rename with Return, open the image preview, drag a local file. Then branch `migrate/step-05b-preferences`. Do not start 5b on this branch.

## Deferred

Text editor in-app checks are still open. Step 4 still needs a live SSH session before any `Process` switch. Upload speed and ETA stay deferred. Cancel on a running upload still disconnects. `GCC_OPTIMIZATION_LEVEL = 0` on Deployment and Default, and the C build rule that names `com.apple.compilers.gcc`, stay for a later settings pass.
