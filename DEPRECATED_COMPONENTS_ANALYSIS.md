# Deprecated Components Analysis - Fugu SFTP Client

This document identifies deprecated files and components in the Fugu SFTP client that can be replaced with modern implementations or contemporary frameworks.

## 🚨 Critical Deprecated Components

### 1. **Distributed Objects (NSConnection) - COMPLETELY DEPRECATED**

**Files affected:**
- `SCPController.m` (lines 44-47)
- `SCPTransfer.m` (line 33, 36)
- `SFTPController.h` (line 196)
- `SFTPController.m` (lines 168-179)

**Current usage:**
```objc
NSConnection *connectionToTServer;
connectionToTServer = [[ NSConnection alloc ] initWithReceivePort: recPort sendPort: sendPort ];
```

**Status:** ❌ **REMOVED in macOS 10.13** - Distributed Objects framework was deprecated and removed
**Modern replacement:** 
- **XPC Services** for inter-process communication
- **NSXPCConnection** for secure, sandboxed IPC
- **Network.framework** for network communication

---

### 2. **Carbon Framework Dependencies - DEPRECATED**

**Files affected:**
- `NSString(FSRefAdditions).h/.m` - File system references
- `NSWorkspace(LaunchServices).h/.m` - Application Services
- `aevent.c/.h` - Apple Events
- `NSAttributedString-Ellipsis.m`
- Multiple build configurations in `project.pbxproj`

**Current usage:**
```c
#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>
FSRef, FSSpec, AliasHandle, Apple Events
```

**Status:** ⚠️ **DEPRECATED** - While still functional, Apple discourages new Carbon usage
**Modern replacements:**
- **Foundation/Cocoa APIs** for file operations
- **NSURL/NSFileManager** instead of FSRef/FSSpec
- **NSWorkspace** instead of Launch Services directly
- **NSAppleScript/OSAScript** instead of raw Apple Events

---

### 3. **Legacy Networking (CFNetwork) - DEPRECATED PATTERNS**

**Files affected:**
- `UMVersionCheck.m` - HTTP version checking

**Current usage:**
```c
CFHTTPMessageRef, CFReadStreamRef for HTTP requests
#define VERSION_URL @"http://rsug.itd.umich.edu/software/fugu/version.plist"
```

**Status:** ⚠️ **DEPRECATED PATTERN** - CFNetwork still works but uses old patterns
**Modern replacements:**
- **NSURLSession** (recommended) - modern, async networking
- **URLSession** in Swift
- **HTTPS instead of HTTP** for security

---

### 4. **Process Management (fork/exec) - OUTDATED PATTERNS**

**Files affected:**
- `sshversion.c` - SSH version detection
- `SCPTransfer.m` - SCP process spawning  
- `ee.c` - External editor launching

**Current usage:**
```c
fork(), execve(), forkpty(), wait()
```

**Status:** ⚠️ **FUNCTIONAL BUT OUTDATED**
**Modern replacements:**
- **NSTask/NSProcess** for subprocess management
- **Process** class in Swift
- **posix_spawn()** instead of fork/exec

---

### 5. **Manual Bonjour Implementation - CAN BE SIMPLIFIED**

**Files affected:**
- `SFTPController.m` (lines 4610+)

**Current usage:**
```objc
NSNetServiceBrowser *sshServiceBrowser;
Manual service discovery and resolution
```

**Status:** ✅ **FUNCTIONAL** but can be modernized
**Modern improvements:**
- **Network.framework** (iOS 12+/macOS 10.14+) 
- Simplified **NWBrowser** APIs
- Better error handling and async patterns

---

## 📋 Recommended Modernization Priority

### **Priority 1: Critical (Breaks on newer macOS)**
1. **Replace Distributed Objects** with XPC Services
2. **Update CFNetwork HTTP** to NSURLSession
3. **Migrate Carbon FSRef/FSSpec** to NSURL/NSFileManager

### **Priority 2: High (Deprecated but working)**
4. **Replace fork/exec** with NSTask/NSProcess
5. **Update Apple Events** to modern NSAppleScript
6. **Modernize version checking** (HTTPS + NSURLSession)

### **Priority 3: Medium (Improvement opportunities)**
7. **Enhance Bonjour** with Network.framework
8. **Update build system** to use modern Xcode features
9. **Add sandboxing support** (requires XPC migration)

---

## 🔄 Specific Replacement Strategies

### **1. Distributed Objects → XPC Services**

**Create separate XPC services for:**
- SFTP operations (`SFTPTServer` functionality)
- SCP transfers (`SCPTransfer` functionality)
- SSH process management

**Benefits:**
- Sandboxing support
- Better security isolation
- Crash resilience
- Modern async patterns

### **2. Carbon APIs → Foundation APIs**

**File operations:**
```objc
// Old Carbon approach
FSRef ref;
FSPathMakeRef((UInt8*)path, &ref, NULL);

// Modern Foundation approach
NSURL *url = [NSURL fileURLWithPath:path];
NSFileManager *fm = [NSFileManager defaultManager];
```

### **3. CFNetwork → NSURLSession**

**Version checking:**
```objc
// Old CFNetwork approach
CFHTTPMessageRef httpMessage = CFHTTPMessageCreateRequest(...);
CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(...);

// Modern NSURLSession approach
NSURLSessionDataTask *task = [[NSURLSession sharedSession] 
    dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Handle response
    }];
```

### **4. Process Management → NSTask**

**SSH execution:**
```objc
// Old fork/exec approach
switch(fork()) {
    case 0: execve(sshpath, sshexec, NULL); break;
}

// Modern NSTask approach
NSTask *task = [[NSTask alloc] init];
task.launchPath = sshPath;
task.arguments = @[@"-V"];
[task launch];
```

---

## 🛡️ Security Improvements

1. **HTTPS everywhere** - Replace HTTP version checking
2. **App sandboxing** - Requires XPC migration
3. **Hardened runtime** - Modern code signing
4. **Network entitlements** - Proper permission declarations

---

## 📊 Effort Estimation

| Component | Effort | Risk | Impact |
|-----------|--------|------|--------|
| Distributed Objects → XPC | **High** | **Medium** | **Critical** |
| Carbon → Foundation | **Medium** | **Low** | **High** |
| CFNetwork → URLSession | **Low** | **Low** | **Medium** |
| fork/exec → NSTask | **Medium** | **Low** | **Medium** |
| Bonjour modernization | **Low** | **Low** | **Low** |

**Total estimated effort:** 4-6 weeks for complete modernization

---

## 🎯 Minimal Viable Modernization

For a **quick modernization** to ensure compatibility:

1. **Replace Distributed Objects** with XPC (essential for future macOS)
2. **Update HTTP to HTTPS** with NSURLSession (security + compatibility)  
3. **Migrate critical Carbon APIs** to Foundation (file operations)

This would address the most critical deprecated components while maintaining functionality on current and future macOS versions.