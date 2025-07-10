# XPC Migration Guide - Replacing Distributed Objects in Fugu

This document provides a comprehensive guide for migrating the Fugu SFTP client from deprecated Distributed Objects (NSConnection) to modern XPC Services.

## 🚨 **Why This Migration is Critical**

- **Distributed Objects were REMOVED in macOS 10.13** (High Sierra)
- The current code **WILL NOT WORK** on modern macOS versions
- XPC provides better security, sandboxing, and crash resilience

## 📋 **Migration Overview**

### **What Was Replaced**

1. **SFTPTServer** (Distributed Objects) → **SFTPService** (XPC Service)
2. **SCPTransfer** (Distributed Objects) → **SCPService** (XPC Service)  
3. **NSConnection-based threading** → **XPC-based inter-process communication**

### **Files Created**

#### **SFTP XPC Service**
- `SFTPService/SFTPServiceProtocol.h` - XPC protocol definition
- `SFTPService/SFTPService.h` - Service interface
- `SFTPService/SFTPService.m` - Service implementation
- `SFTPService/main.m` - XPC service main
- `SFTPService/Info.plist` - Service bundle info

#### **SCP XPC Service**
- `SCPService/SCPServiceProtocol.h` - XPC protocol definition
- `SCPService/SCPService.h` - Service interface
- `SCPService/SCPService.m` - Service implementation  
- `SCPService/main.m` - XPC service main
- `SCPService/Info.plist` - Service bundle info

#### **Integration Layer**
- `SFTPControllerXPC.h` - XPC connection manager
- `SFTPControllerXPC.m` - XPC connection implementation

## 🔄 **Key Architecture Changes**

### **Before (Distributed Objects)**
```objc
// Old threading + Distributed Objects approach
NSConnection *connectionToTServer = [[NSConnection alloc] initWithReceivePort:recPort sendPort:sendPort];
[connectionToTServer setRootObject:self];
[NSThread detachNewThreadSelector:@selector(connectWithPorts:) 
                           toTarget:[SFTPTServer class] 
                         withObject:portArray];
```

### **After (XPC Services)**
```objc
// Modern XPC approach
NSXPCConnection *sftpConnection = [[NSXPCConnection alloc] initWithServiceName:@"edu.umich.fugu.SFTPService"];
sftpConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SFTPServiceProtocol)];
[sftpConnection resume];
id<SFTPServiceProtocol> sftpService = [sftpConnection remoteObjectProxy];
```

## 🛠 **Implementation Details**

### **1. SFTP Service Protocol**

The XPC protocol replaces the old `SFTPTServerInterface`:

```objc
@protocol SFTPServiceProtocol
- (void)connectToServerWithParams:(NSArray *)params 
                       completion:(void (^)(BOOL success, NSString *error))completion;
- (void)collectDirectoryListingWithCompletion:(void (^)(NSArray *listing, NSString *error))completion;
- (void)uploadFile:(NSString *)localPath remotePath:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion;
// ... additional methods
@end
```

### **2. Asynchronous Completion Blocks**

XPC uses modern async patterns instead of synchronous calls:

```objc
// Old synchronous approach
NSArray *listing = [tServer collectListing];

// New asynchronous approach  
[sftpService collectDirectoryListingWithCompletion:^(NSArray *listing, NSString *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI on main thread
        [self updateListingUI:listing];
    });
}];
```

### **3. Error Handling**

XPC provides structured error handling:

```objc
[sftpService connectToServerWithParams:params completion:^(BOOL success, NSString *error) {
    if (!success) {
        NSLog(@"Connection failed: %@", error);
        // Handle error appropriately
    }
}];
```

## 🏗 **Xcode Project Configuration**

### **Add XPC Service Targets**

1. **Add SFTPService Target:**
   - Product Type: XPC Service
   - Bundle Identifier: `edu.umich.fugu.SFTPService`
   - Deployment Target: macOS 10.9+

2. **Add SCPService Target:**
   - Product Type: XPC Service  
   - Bundle Identifier: `edu.umich.fugu.SCPService`
   - Deployment Target: macOS 10.9+

### **Update Main App Target**

Add XPC services as dependencies:
- Build Phases → Copy Files → Add SFTPService.xpc
- Build Phases → Copy Files → Add SCPService.xpc

### **Update Build Settings**

```
// Remove old Distributed Objects references
// Add XPC entitlements if needed for sandboxing
```

## 🔌 **Integration Steps**

### **Step 1: Update SFTPController**

Replace Distributed Objects setup:

```objc
// In SFTPController.m init method
// Replace:
// [self establishDOConnection];

// With:
self.xpcController = [[SFTPControllerXPC alloc] init];
```

### **Step 2: Update Method Calls**

Convert synchronous DO calls to async XPC:

```objc
// Old approach
- (void)getListing {
    [tServer collectListingFromMaster:master fileStream:mf forController:self];
}

// New approach  
- (void)getListing {
    [self.xpcController getDirectoryListingWithCompletion:^(NSArray *listing, NSString *error) {
        if (error) {
            [self handleError:error];
        } else {
            [self loadRemoteBrowserWithItems:listing];
        }
    }];
}
```

### **Step 3: Update SCPController**

Similar changes for SCP operations:

```objc
// Replace SCPTransfer DO calls with SCPService XPC calls
[self.xpcController performSCP:userAtHost port:port item:item scpType:scpType 
                    completion:^(BOOL success, NSString *error) {
    // Handle completion
}];
```

## 🧪 **Testing the Migration**

### **Unit Tests**
- Test XPC service connectivity
- Test SFTP operations through XPC
- Test SCP operations through XPC
- Test error handling and timeouts

### **Integration Tests**
- Test full connection workflow
- Test file transfer operations
- Test UI updates with async callbacks

### **Compatibility Tests**
- Test on macOS 10.9+ (minimum supported)
- Test on current macOS versions
- Test both Intel and Apple Silicon

## 🛡 **Security Benefits**

### **Process Isolation**
- SFTP/SCP operations run in separate processes
- Crash in service doesn't crash main app
- Better memory isolation

### **Sandboxing Support**
- XPC services can be sandboxed
- Restricted file system access
- Network access control

### **Permission Management**
- Explicit entitlements for capabilities
- Reduced attack surface
- Better security auditing

## ⚠️ **Known Limitations & Considerations**

### **Performance**
- XPC has slight overhead vs. threading
- Need to serialize data across process boundaries
- Consider batch operations for efficiency

### **Debugging**
- XPC services run in separate processes
- Need to attach debugger to service processes
- Use Console.app for XPC service logs

### **Deployment**
- XPC services must be embedded in app bundle
- Code signing requirements for services
- Entitlements may be needed

## 📊 **Migration Checklist**

- [ ] Create SFTP XPC service target
- [ ] Create SCP XPC service target  
- [ ] Implement XPC protocols
- [ ] Create SFTPControllerXPC wrapper
- [ ] Update SFTPController to use XPC
- [ ] Update SCPController to use XPC
- [ ] Remove old Distributed Objects code
- [ ] Add XPC services to app bundle
- [ ] Test on multiple macOS versions
- [ ] Update build configurations
- [ ] Document new architecture

## 🎯 **Minimal Integration**

For a **quick migration** to restore functionality:

1. **Add XPC service targets** to Xcode project
2. **Replace `establishDOConnection`** with `SFTPControllerXPC` initialization
3. **Update key SFTP methods** to use async XPC calls
4. **Test basic connectivity** and file operations

This restores core functionality while maintaining the existing UI and user experience.

## 🚀 **Future Enhancements**

Once XPC migration is complete:

1. **Add sandboxing** for enhanced security
2. **Implement progress reporting** for transfers
3. **Add connection pooling** for efficiency
4. **Enhanced error recovery** mechanisms
5. **Background transfer support**

The XPC architecture provides a solid foundation for these modern features while ensuring compatibility with current and future macOS versions.