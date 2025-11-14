# PortPal Security & Configuration Guide

## API Keys Configuration

PortPal uses several external APIs that require authentication. This guide explains how to securely configure your API keys.

### AISStream API Key

The app uses [AISStream.io](https://aisstream.io) for real-time ship tracking via AIS (Automatic Identification System) data.

#### Setup Instructions:

1. **Get an API Key**
   - Visit https://aisstream.io
   - Sign up for a free account
   - Copy your API key from the dashboard

2. **Configure the Key** (Choose ONE method):

   **Option A: Info.plist (Recommended for Team Development)**
   ```xml
   <key>AISStreamAPIKey</key>
   <string>YOUR_API_KEY_HERE</string>
   ```

   **Option B: Environment Variable**
   - Add to your shell profile (`.zshrc`, `.bashrc`, etc.):
   ```bash
   export AIS_STREAM_API_KEY="your_api_key_here"
   ```

   **Option C: Direct in Config.swift (Development Only)**
   - Edit `/Utilities/Config.swift`
   - Replace the development fallback key
   - **⚠️ NEVER commit this file with your real API key!**

### Future API Keys

#### Weather API (Planned)

Add to Info.plist:
```xml
<key>WeatherAPIKey</key>
<string>YOUR_WEATHER_API_KEY</string>
```

## Security Best Practices

### DO:
✅ Use environment variables or Info.plist for API keys
✅ Keep sensitive keys out of version control
✅ Use different keys for development and production
✅ Rotate API keys regularly
✅ Use minimal permissions for API keys

### DON'T:
❌ Commit API keys to Git
❌ Share API keys in public channels
❌ Use production keys in debug builds
❌ Hardcode API keys in source files
❌ Include keys in screenshots or bug reports

## .gitignore Configuration

The `.gitignore` file includes patterns to prevent accidental commits of sensitive data:

```gitignore
# Optionally exclude Config.swift if you store keys there
# Config.swift
```

If your team decides to exclude `Config.swift` from version control, uncomment that line and create a `Config-template.swift` that developers can copy and customize.

## Production Deployment

For App Store builds:

1. **Use Xcode Configuration Settings**
   - Create separate configurations for Debug/Release
   - Use different API keys per environment

2. **CI/CD Integration**
   - Store keys in CI/CD secrets (GitHub Actions, Bitrise, etc.)
   - Inject keys during build process

3. **Keychain Storage**
   - For highly sensitive data, consider using iOS Keychain
   - Implement in `PersistenceController` or separate `KeychainService`

## Audit Log

### Recent Security Improvements

- **2024-11-14**: Moved API key from hardcoded string to `Config.swift`
- **2024-11-14**: Added support for Info.plist and environment variable configuration
- **2024-11-14**: Created security documentation
- **2024-11-14**: Updated `.gitignore` to include security-related files

## Questions?

For security concerns or to report vulnerabilities, contact: security@portpal.app
