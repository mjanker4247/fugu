# XPC Service Project Setup Guide

This guide provides instructions for adding the XPC service targets to the Fugu Xcode project.

## Adding XPC Service Targets

### 1. Add SFTPService Target

1. Open `Fugu.xcodeproj` in Xcode
2. Right-click on the project in the navigator
3. Select "Add Target..."
4. Choose "XPC Service" template
5. Configure the target:
   - **Product Name**: `SFTPService`
   - **Bundle Identifier**: `edu.umich.fugu.SFTPService`
   - **Language**: Objective-C
   - **Deployment Target**: macOS 10.9+

### 2. Add SCPService Target

1. Repeat the same process for SCP service
2. Configure the target:
   - **Product Name**: `SCPService`
   - **Bundle Identifier**: `edu.umich.fugu.SCPService`
   - **Language**: Objective-C
   - **Deployment Target**: macOS 10.9+

## Add Source Files to Targets

### SFTPService Target
Add these files to the SFTPService target:
- `SFTPService/SFTPServiceProtocol.h`
- `SFTPService/SFTPService.h`
- `SFTPService/SFTPService.m`
- `SFTPService/main.m`
- `SFTPService/Info.plist`

### SCPService Target
Add these files to the SCPService target:
- `SCPService/SCPServiceProtocol.h`
- `SCPService/SCPService.h`
- `SCPService/SCPService.m`
- `SCPService/main.m`
- `SCPService/Info.plist`

## Update Main App Target

### Add XPC Services as Dependencies

1. Select the main `Fugu` target
2. Go to "Build Phases" tab
3. Expand "Copy Files" phase
4. Add both XPC services:
   - `SFTPService.xpc`
   - `SCPService.xpc`

### Add XPC Controller Files

Add these files to the main Fugu target:
- `SFTPControllerXPC.h`
- `SFTPControllerXPC.m`

## Build Settings

### SFTPService Target
- **Deployment Target**: macOS 10.9+
- **Architectures**: $(ARCHS_STANDARD)
- **Base SDK**: Latest macOS

### SCPService Target
- **Deployment Target**: macOS 10.9+
- **Architectures**: $(ARCHS_STANDARD)
- **Base SDK**: Latest macOS

## Testing the Setup

1. Build the project (`Cmd+B`)
2. Check that all targets build successfully
3. Run the main app and test SFTP/SCP functionality
4. Verify XPC services are embedded in the app bundle

## Troubleshooting

### Common Issues

1. **Missing XPC services in app bundle**
   - Ensure XPC services are added to "Copy Files" phase
   - Check that services are built before main app

2. **Connection failures**
   - Verify service bundle identifiers match
   - Check Console.app for XPC service logs

3. **Build errors**
   - Ensure all source files are added to correct targets
   - Check that deployment targets are compatible

## Next Steps

After setting up the XPC targets:

1. Test basic connectivity
2. Test file transfer operations
3. Test error handling
4. Add sandboxing if needed
5. Optimize performance

The XPC architecture provides a modern, secure foundation for the Fugu SFTP client. 