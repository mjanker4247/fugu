# Active Context

## Current Focus

Upgrade `Fugu.xcodeproj` to a consistent Xcode 27 project. Level 3. VAN finished on 8 Nov 2026. Implementation is blocked until PLAN.

## Status

This Mac has Xcode 27.2 (27B52) and the macOS 27.2 SDK. `LastUpgradeCheck` is already `2720`, and earlier Development builds succeeded. The project file is still `objectVersion` 54 / `compatibilityVersion` Xcode 12.0. Project deployment is `11.5`. The Fugu target uses `$(RECOMMENDED_MACOSX_DEPLOYMENT_TARGET)`, which this SDK sets to `27.2`. Target configs still pin `CC` to `/usr/bin/gcc` and Development still sets `ZERO_LINK = YES`.

## Next action

PLAN. The plan has to pick one deployment target and say whether the project format stays at Xcode 12 compatibility. Do not edit `project.pbxproj` before that.

## Deferred

Text editor in-app checks are still open. Step 4 still needs a live SSH session before any `Process` switch. Do not start Step 5. Upload speed and ETA stay deferred.
