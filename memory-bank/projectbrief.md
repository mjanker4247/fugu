# Project Brief

Fugu 1.2.1b is a macOS SFTP/SCP client (bundle id `edu.umich.fugu`). It browses a local folder and a remote SFTP folder, copies with SCP, and manages SSH local forwards. The UI is AppKit XIBs. The transfer engine shells out to the system `sftp`, `scp`, and `ssh` binaries.

## Current task

The Xcode 27 upgrade is archived in `memory-bank/archive/archive-xcode27.md`. The deployment floor is macOS 14.0. The open work is the text-editor in-app checks, then the parked Swift migration. Step 5 has not started.

## Task

Incrementally migrate the Objective-C/C codebase to idiomatic Swift and a feature-based on-disk layout. Every step must keep the app building and behaviorally identical. There is no automated test suite.

## Development host

All implementation and verification happen on the local Mac with Xcode. The Linux workspace does not build or run the app.

## Non-goals for the first step

No Swift rewrites of controllers, no SSH library swap, no SwiftUI conversion, no deployment-target change.

## Editor setting

File Editing currently chooses from a fixed ODB editor list and defaults to BBEdit. A later change lets the user pick an installed editor, including modern editors, and caches that installed list. The migration above stays parked while that change is planned and built. `SFTPPrefs` stays Objective-C for this change.
