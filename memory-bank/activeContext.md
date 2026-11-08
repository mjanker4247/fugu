# Active Context

## Current Focus

Step 5b preferences, on `migrate/step-05b-preferences`. The preferences class is Swift. Preferences smoke is still open.

## Status

Step 5a is commit `f94884f` on `migrate/step-05a-browser-views`. `SFTPPrefs` and `SFTPPrefTableView` are Swift on this branch. `Prefs.xib` sets `customModule="Fugu"` on the owner and both tables. Known hosts still go through `acav_parse`. Development `xcodebuild` succeeded on 8 Nov 2026. SCP, the tunnel, and `SFTPController` stay Objective-C.

## Next action

Smoke the preferences panel: each toolbar pane, add and delete a favorite, open known hosts. Then branch `migrate/step-05c-scp`. Do not start 5c on this branch.

## Deferred

Text editor in-app checks are still open. Step 4 still needs a live SSH session before any `Process` switch. Upload speed and ETA stay deferred. Cancel on a running upload still disconnects. `GCC_OPTIMIZATION_LEVEL = 0` on Deployment and Default, and the C build rule that names `com.apple.compilers.gcc`, stay for a later settings pass.
