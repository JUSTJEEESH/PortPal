//
//  Config.swift
//  PortPal
//
//  Configuration and API keys
//  IMPORTANT: Add Config.swift to .gitignore to keep secrets private
//

import Foundation

struct Config {
    // MARK: - API Keys

    /// AISStream API Key
    /// Get your key at: https://aisstream.io
    static var aisStreamAPIKey: String {
        // Try to load from Info.plist first (recommended for production)
        if let key = Bundle.main.object(forInfoDictionaryKey: "AISStreamAPIKey") as? String, !key.isEmpty {
            return key
        }

        // Fallback to environment variable
        if let key = ProcessInfo.processInfo.environment["AIS_STREAM_API_KEY"], !key.isEmpty {
            return key
        }

        // Development fallback (replace with your own key for local development)
        #if DEBUG
        return "ab02bcdf98a2c1568f8a5abefb2851bc3b889477"  // Development key only
        #else
        fatalError("AISStream API key not configured. Add it to Info.plist or environment variables.")
        #endif
    }

    // MARK: - Feature Flags

    /// Enable or disable real ship tracking
    static var enableRealShipTracking: Bool {
        #if DEBUG
        return true  // Enabled in debug builds
        #else
        return true  // Enabled in production
        #endif
    }

    /// Enable or disable ship tracking service logging
    static var enableTrackingLogs: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    // MARK: - App Configuration

    /// Base URL for future API endpoints
    static let baseAPIURL = "https://api.portpal.app"  // Placeholder

    /// Weather API configuration (for future implementation)
    static var weatherAPIKey: String? {
        return Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String
    }

    /// App version
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    /// Build number
    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}
