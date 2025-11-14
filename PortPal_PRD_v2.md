# PortPal - Product Requirements Document (PRD)

**Version:** 2.0  
**Last Updated:** November 13, 2025  
**Product Owner:** Josh  
**Target Platform:** iOS 18+  

---

## Executive Summary

PortPal is a comprehensive cruise ship tracking and port departure timer application for iOS that helps cruise passengers never miss their ship. Inspired by the award-winning Flighty app's UX excellence, PortPal provides real-time ship tracking, urgency-based countdown timers, and comprehensive cruise itineraries with a clean, native iOS aesthetic.

**Core Value Proposition:** Peace of mind for cruise passengers exploring ports of call, with beautiful design and reliable real-time tracking.

---

## Product Vision

### Mission Statement
To be the most trusted and beautiful port departure tracking app for cruise passengers worldwide, eliminating the anxiety of missing ship departures while maximizing exploration time at ports.

### Target Audience
- **Primary:** Cruise passengers on major cruise lines (Royal Caribbean, Carnival, Norwegian, Disney, Celebrity, Princess, MSC, etc.)
- **Secondary:** Frequent cruisers who take multiple trips per year
- **Geographic Focus:** North America, Caribbean, and Central America (expanding globally)

### Success Metrics
- **Adoption:** 100K downloads in first year
- **Engagement:** 80%+ DAU during active cruises
- **Retention:** 70%+ users return for their next cruise
- **Rating:** 4.8+ stars on App Store
- **Revenue:** Premium features subscription model ($4.99/month or $29.99/year)

---

## User Personas

### Persona 1: Sarah - The Anxious Explorer
- **Age:** 45, First-time cruiser
- **Pain Point:** Terrified of missing the ship at port stops
- **Needs:** Clear, simple countdown timers with plenty of warning time
- **Behavior:** Checks app constantly, sets phone reminders, returns to ship early

### Persona 2: Mike - The Adventure Seeker  
- **Age:** 32, Experienced cruiser (5+ cruises)
- **Pain Point:** Wants to maximize port time without stress
- **Needs:** Accurate real-time ship position, trust in the app's alerts
- **Behavior:** Pushes departure times but relies on technology to keep safe

### Persona 3: The Johnson Family
- **Age:** Parents (38, 40) with kids (8, 12)
- **Pain Point:** Coordinating family return to ship
- **Needs:** Simple visual indicators everyone can understand
- **Behavior:** One parent monitors app while other supervises kids

---

## Core Features & Requirements

## 1. Countdown Timer System

### 1.1 Main Countdown Display

**Requirements:**
- Large, circular progress ring showing time remaining until next port departure
- Center displays: countdown timer, port name, and current state message
- Ring color dynamically changes based on urgency (green → yellow → orange → red → gray)
- Smooth animations with no jarring transitions
- Monospaced font for timer to prevent layout shifts

**Urgency States:**

| State | Time Remaining | Ring Color | Message | Behavior |
|-------|---------------|------------|---------|----------|
| **All Good** | 7+ hours | Caribbean Cyan (#00D4AA) | "Relax and Enjoy" | Standard updates |
| **Stay Alert** | 3-7 hours | Sunshine Yellow (#FFD54F) | "Stay Alert" | More frequent checks |
| **Departing Soon** | 1-3 hours | Sunset Orange (#FF6B35) | "Departing Soon" | Frequent updates, gentle vibration |
| **Return Now** | 45 min - 1 hour | Coral Red (#FF1744) | "Return to Ship NOW" | Pulsing animation, repeated alerts, screen stays awake |
| **Ship Departed** | Past departure | Steel Gray (#6B7280) | "Ship Has Departed" | Emergency contact info, gray ring |

**Technical Specs:**
- Update frequency: Every second for active countdown
- Ring diameter: 200pt on iPhone, 140pt on Apple Watch
- Stroke width: 12pt
- Animation duration: 1 second per update with ease-in-out
- Glow effect: Subtle shadow matching ring color, intensifies in critical state

### 1.2 Multiple Port Handling

**Requirements:**
- Automatically switches to next port after current port departure
- Shows only intermediate port stops (excludes embarkation and final return port)
- Swipe gesture to preview upcoming ports
- Maintains accurate state even when backgrounded

**State Transitions:**

```
Embarkation Day
    ↓
Setting Sail Soon (6 hours before first port arrival)
    ↓
Seas the Day (at sea between ports)
    ↓
Exploration Time (at port, countdown active)
    ↓
Land Ho (approaching next port)
    ↓
[Repeat for each port]
    ↓
Final Return (last day, heading home)
```

---

## 2. Ship Tracking & Real-Time Position

### 2.1 AIS Integration

**Requirements:**
- Display ship's real-time position on map using AIS data
- Update position every 30 seconds when app is active
- Update every 5 minutes when backgrounded
- Show ship heading indicator
- Smooth position interpolation between updates

**Data Sources (Priority Order):**
1. **AISStream.io** - WebSocket real-time streaming
2. **VesselFinder API** - REST API polling
3. **MarineTraffic API** - Backup data source
4. **Position API** - Alternative source

**Technical Implementation:**
```swift
// AIS Data Model
struct ShipPosition {
    let mmsi: String           // Ship's unique AIS identifier
    let latitude: Double       // Decimal degrees
    let longitude: Double      // Decimal degrees
    let heading: Double?       // 0-359 degrees, optional
    let speed: Double?         // Knots
    let timestamp: Date        // Position timestamp
    let source: String         // Data source identifier
}

// Update Strategy
- Active app: WebSocket streaming (30s updates)
- Background: Scheduled polling (5min updates)
- No connection: Continue countdown with cached data
- Position accuracy: Display only if <15 minutes old
```

### 2.2 Map View

**Requirements:**
- Dark mode map style optimized for ocean visibility
- Ship marker: Top-down ship icon with heading indicator
- Route visualization: Animated dotted line connecting ports
- Port markers: Labeled pins at each destination
- Interactive controls: Zoom, center on ship, map/satellite toggle
- Current position accuracy indicator
- Distance to next port

**Map Features:**
- Tap ship marker → Show current speed, heading, distance to port
- Tap port marker → Show port details and arrival time
- Route path: Pink dotted line (#FF1E8D) with marching animation
- Ship trail: Faded path showing recent movement (last 4 hours)

---

## 3. Cruise Database & Itinerary

### 3.1 Cruise Ship Database

**Requirements:**
- Comprehensive database of major cruise lines' ships
- Support for 500+ ships initially
- Ship details: Name, MMSI, capacity, tonnage, year built, cruise line
- High-quality ship photos (at least 1 hero image per ship)
- Regular database updates (weekly sync)

**Coverage:**

| Cruise Line | Ships | Priority |
|-------------|-------|----------|
| Royal Caribbean | 28 ships | High |
| Carnival | 24 ships | High |
| Norwegian | 18 ships | High |
| Disney | 5 ships | High |
| Celebrity | 14 ships | High |
| Princess | 15 ships | Medium |
| MSC | 22 ships | Medium |
| Holland America | 11 ships | Medium |
| Costa | 12 ships | Low |
| Others | ~350 ships | Low |

### 3.2 Itinerary System

**Requirements:**
- Accurate port schedules for all Caribbean routes initially
- Expandable to North America and Central America
- Port details: Name, arrival time, departure time, pier/terminal code
- Support for any embarkation date
- Template system: Store relative "Day X" format, calculate actual dates based on embarkation
- Multi-port day handling (rare, but possible)
- Time zone accuracy for each port

**Data Model:**
```swift
struct CruiseItinerary {
    let cruiseID: String
    let shipMMSI: String
    let cruiseName: String          // e.g., "7 Day Western Caribbean"
    let cruiseLine: String
    let ship: Ship
    let embarkationDate: Date
    let duration: Int               // Days
    let ports: [PortStop]
    let totalDistance: Double?      // Nautical miles
}

struct PortStop {
    let dayNumber: Int              // Day 1, Day 2, etc.
    let portName: String
    let portCode: String            // IATA or custom code
    let countryCode: String
    let arrivalTime: String         // "10:10 AM" format
    let departureTime: String       // "6:00 PM" format
    let pierTerminal: String?       // "A19", "Puerta Maya", etc.
    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
    let durationAtPort: TimeInterval
    let isSeaDay: Bool = false
}
```

### 3.3 CruiseMapper Scraper Integration

**Requirements:**
- Automated web scraper for CruiseMapper.com
- Extract: Ship schedules, itineraries, port info, MMSI numbers
- Run weekly to update database
- Manual trigger option for specific ships/routes
- Data validation and conflict resolution
- Error logging and monitoring

**Scraped Data Points:**
- Ship name and details
- MMSI number (critical for AIS tracking)
- Complete itinerary with dates
- Port names and codes
- Arrival/departure times
- Pier/terminal information
- Ship specifications

---

## 4. Notifications & Alerts

### 4.1 Push Notifications

**Requirements:**
- Time-sensitive notifications using iOS UNNotificationRequest
- Critical alerts for departure urgency
- Rich notifications with ship photo and map
- Action buttons: "View Map", "Show Itinerary", "Snooze"

**Notification Schedule:**

| Event | Timing | Priority | Repeat |
|-------|--------|----------|--------|
| **Arrival Reminder** | 1 hour before arrival | Normal | Once |
| **First Warning** | 3 hours before departure | Normal | Once |
| **Second Warning** | 1 hour before departure | Time-Sensitive | Once |
| **Critical Alert** | 45 minutes before departure | Critical | Every 15 min |
| **Final Warning** | 30 minutes before departure | Critical | Every 10 min |
| **Departed** | At departure time | Critical | Once |

**Notification Content Examples:**

```
🚢 Arrival Reminder (1hr before)
Title: "10:10 AM ROATÁN"
Body: "Get ready to explore Roatán!"
Badge: "A19"

⚠️ First Warning (3hr before)
Title: "Departing in 3 hours"
Body: "Roatán • All aboard by 6:00 PM • Pier A19"

🚨 Critical Alert (45min before)
Title: "RETURN TO SHIP NOW"
Body: "Ship departs in 45 minutes!"
Actions: [View Map] [I'm On Board]
```

### 4.2 Live Activities

**Requirements:**
- Active countdown displayed in Dynamic Island (iPhone 14 Pro+)
- Lock screen Live Activity widget
- Always-on display support
- Updates every minute when active

**Dynamic Island States:**
- **Compact:** Port code + countdown (mm:ss)
- **Minimal:** Countdown only with urgency color
- **Expanded:** Full countdown ring, port name, ship name, urgency message

---

## 5. Apple Watch Integration

### 5.1 Watch App

**Requirements:**
- Standalone Watch app with full countdown functionality
- Syncs automatically with iPhone app
- Watch face complications (all sizes)
- Haptic alerts based on urgency
- Glanceable countdown ring design

**Watch Complications:**
- **Circular Small:** Timer only
- **Circular Large:** Ring + timer + port code
- **Rectangular:** Port name + timer + pier
- **Corner:** Curved timer with port code
- **Extra Large:** Full ring display

### 5.2 Watch Face Examples

**Modular Face:**
- Large center: Countdown ring + timer
- Top: Ship name
- Bottom: Port name + state message

**Infograph Face:**
- Corner complication: Curved timer
- Center complication: Full countdown ring
- Sub-dial: Urgency indicator

---

## 6. User Interface Design

### 6.1 Design Principles

1. **Native iOS Aesthetic:** Clean, sophisticated, no excessive color or emojis
2. **Urgency-First:** Color psychology guides user behavior
3. **Information Hierarchy:** Most important info largest and most prominent
4. **Smooth Interactions:** No janky scrolling, no gesture conflicts
5. **Breathing Room:** Adequate spacing, not cluttered
6. **Accessibility:** Full VoiceOver support, Dynamic Type, high contrast

### 6.2 Visual Design System

**Color Palette:**
- Primary Background: Navy Dark (#0A1628)
- Card Background: Dark Slate (#1A2332)
- Accent: Ocean Teal (#00A5CF)
- Success: Caribbean Cyan (#00D4AA)
- Warning: Sunshine Yellow (#FFD54F)
- Urgent: Sunset Orange (#FF6B35)
- Critical: Coral Red (#FF1744)
- Secondary Text: Steel Gray (#6B7280)

**Typography:**
- Primary Font: SF Pro (system default)
- Countdown Timer: SF Mono (monospaced for stability)
- Sizes: Follow iOS Dynamic Type scale
- Weights: Regular, Semibold, Bold

**Effects:**
- Ocean Gradient Background: Animated slow parallax
- Frosted Glass: Cards and overlays use iOS material blur
- Glow Effects: Subtle shadows matching countdown ring color
- Smooth Animations: 0.35s duration, ease-in-out curve

### 6.3 Screen Layouts

#### Main Countdown Screen
```
┌─────────────────────────────────┐
│  [Ship Name]          [Settings]│ ← Navigation Bar
├─────────────────────────────────┤
│                                 │
│     EXPLORATION TIME ⏰          │ ← State Banner
│                                 │
│         ╔═══════════╗           │
│         ║           ║           │
│         ║  6h 45m   ║           │ ← Countdown Ring
│         ║  ROATÁN   ║           │
│         ║ All Good ✓║           │
│         ╚═══════════╝           │
│                                 │
│  COZ 4:30PM  ─────→  10:10AM ROA│ ← Timeline
│   Depart            Arrive      │
│                                 │
│  🗺️ View Map   📋 Itinerary     │ ← Quick Actions
│                                 │
└─────────────────────────────────┘
│ Timer │ Map │ Itinerary │ Cruises│ ← Tab Bar
└─────────────────────────────────┘
```

#### Itinerary Screen
```
┌─────────────────────────────────┐
│  < Oasis of the Seas           │ ← Navigation
├─────────────────────────────────┤
│                                 │
│  [Ship Photo]                   │
│  Oasis of the Seas              │ ← Expanded Cruise Card
│  Royal Caribbean                │   (Collapsible)
│  Built 2009 • 5,400 passengers  │
│                                 │
├─────────────────────────────────┤
│  PORT CANAVERAL                 │
│  4:30 PM • Depart               │     [—]
│  At Arrival 4:30 PM             │
├─────────────────────────────────┤
│  COCO BAY                       │
│  7:00 AM • Arrive               │     [A12]
│  5:00 PM • Depart               │
│  At Arrival 5:00 PM             │
├─────────────────────────────────┤
│  ROATÁN                         │
│  7:00 AM • Arrive               │     [A19]
│  4:00 PM • Depart               │
│  At Arrival 4:00 PM             │
├─────────────────────────────────┤
│  COSTA MAYA                     │
│  11:00 AM • Arrive              │     [—]
│  7:00 PM • Depart               │
└─────────────────────────────────┘
```

#### Map Screen
```
┌─────────────────────────────────┐
│  [🗺️ Map View]      [⋯]         │ ← Top Bar
│                                 │
│     ╔═══════════════════╗       │
│     ║  RC1345  🚢       ║       │ ← Ship Info Card
│     ║  PORTPAL          ║       │   (Frosted Glass)
│     ║  COZ ──→ ROA      ║       │
│     ╚═══════════════════╝       │
│                                 │
│                                 │
│         [Map Content]           │
│         • Ship marker           │ ← Interactive Map
│         • Route line            │
│         • Port markers          │
│                                 │
│                     [🎯]         │ ← Center on Ship
│                                 │
└─────────────────────────────────┘
```

#### My Cruises Screen
```
┌─────────────────────────────────┐
│  My Cruises         [+]         │ ← Navigation
├─────────────────────────────────┤
│  🚢 Cruisey McCruiseface 🗑️     │
│                                 │ ← Selected Cruise
│  ALL-TIME PORTPAL PASSPORT      │   (Can Delete)
│  🔐 • 🛂 • 🛂                    │
│                                 │
│  CRUISES: 3    DISTANCE: 1,675mi│
│  DAYS AT SEA: 17  COUNTRIES: 9  │
│  PORTS: 5                       │
│                                 │
│  [⚙️] Manage Stats              │
├─────────────────────────────────┤
│  📊 Most Cruised Ship            │
│  Harmony of the Seas            │
│  Royal Caribbean                │
│                                 │
│  [Ship Image]                   │
├─────────────────────────────────┤
│  Past Cruises           3 Total │
│                                 │
│  🚢 7 Day Western Caribbean  →  │
│     Oct 2024                    │
│                                 │
│  🚢 5 Day Western Caribbean  →  │
│     Aug 2024                    │
└─────────────────────────────────┘
```

---

## 7. Data Architecture

### 7.1 Local Database (Core Data)

**Entities:**

```swift
// Ship Entity
@Entity Ship {
    @Attribute var mmsi: String          // Primary key
    @Attribute var name: String
    @Attribute var cruiseLine: String
    @Attribute var builtYear: Int
    @Attribute var grossTonnage: Int
    @Attribute var passengerCapacity: Int
    @Attribute var crewCount: Int
    @Attribute var length: Double        // Meters
    @Attribute var beam: Double          // Meters
    @Attribute var imageURL: String?
    @Relationship var cruises: [Cruise]
}

// Cruise Entity
@Entity Cruise {
    @Attribute var id: UUID              // Primary key
    @Attribute var name: String
    @Attribute var embarkationDate: Date
    @Attribute var duration: Int
    @Attribute var isActive: Bool
    @Attribute var createdAt: Date
    @Relationship var ship: Ship
    @Relationship var ports: [Port]
}

// Port Entity
@Entity Port {
    @Attribute var id: UUID              // Primary key
    @Attribute var dayNumber: Int
    @Attribute var name: String
    @Attribute var code: String
    @Attribute var countryCode: String
    @Attribute var arrivalTime: String   // "HH:mm" 24-hour format
    @Attribute var departureTime: String
    @Attribute var pierTerminal: String?
    @Attribute var latitude: Double
    @Attribute var longitude: Double
    @Attribute var timezoneIdentifier: String
    @Attribute var isSeaDay: Bool
    @Relationship var cruise: Cruise
}

// ShipPosition Entity (Cached positions)
@Entity ShipPosition {
    @Attribute var id: UUID
    @Attribute var mmsi: String
    @Attribute var latitude: Double
    @Attribute var longitude: Double
    @Attribute var heading: Double?
    @Attribute var speed: Double?
    @Attribute var timestamp: Date
    @Attribute var source: String
}

// UserPreferences Entity
@Entity UserPreferences {
    @Attribute var notificationsEnabled: Bool
    @Attribute var arrivalRemindersEnabled: Bool
    @Attribute var departureWarningsEnabled: Bool
    @Attribute var warningLeadTime: Int          // Hours
    @Attribute var showShipPosition: Bool
    @Attribute var animateBackground: Bool
    @Attribute var use24HourFormat: Bool
    @Attribute var syncToWatch: Bool
    @Attribute var watchComplicationsEnabled: Bool
    @Attribute var hapticAlertsEnabled: Bool
    @Attribute var distanceUnit: String          // "nm", "km", "mi"
}
```

### 7.2 Remote Database (Firebase Firestore)

**Collections:**

```
cruises/
  {cruiseId}/
    - name: String
    - shipMMSI: String
    - cruiseLine: String
    - duration: Int
    - route: String
    - imageURL: String
    - lastUpdated: Timestamp
    
    ports/
      {portId}/
        - dayNumber: Int
        - name: String
        - code: String
        - arrivalTime: String
        - departureTime: String
        - pierTerminal: String
        - coordinates: GeoPoint
        - timezone: String

ships/
  {mmsi}/
    - name: String
    - cruiseLine: String
    - specs: Map
    - imageURL: String
    - aisSourcePriority: Array
    - lastUpdated: Timestamp

aisCache/
  {mmsi}/
    - latitude: Number
    - longitude: Number
    - heading: Number
    - speed: Number
    - timestamp: Timestamp
    - source: String
    - accuracy: String
```

### 7.3 API Integrations

**AISStream.io WebSocket:**
```javascript
// Connection
wss://stream.aisstream.io/v0/stream

// Authentication
{
  "APIKey": "YOUR_API_KEY",
  "BoundingBoxes": [
    [
      [minLat, minLon],
      [maxLat, maxLon]
    ]
  ],
  "FiltersShipMMSI": ["367123450", "311705000", ...],
  "FilterMessageTypes": ["PositionReport"]
}

// Response
{
  "MessageType": "PositionReport",
  "MetaData": {
    "MMSI": "367123450",
    "ShipName": "OASIS OF THE SEAS",
    "time_utc": "2025-11-13T18:30:00Z"
  },
  "Message": {
    "PositionReport": {
      "Latitude": 18.4567,
      "Longitude": -86.9123,
      "TrueHeading": 245,
      "SpeedOverGround": 12.5
    }
  }
}
```

**CruiseMapper Scraper API:**
```python
# Endpoint: Internal service
GET /api/scraper/ship/{shipName}
GET /api/scraper/itinerary/{cruiseId}

# Response
{
  "ship": {
    "name": "Oasis of the Seas",
    "mmsi": "311705000",
    "cruiseLine": "Royal Caribbean",
    "specs": {...}
  },
  "itinerary": {
    "cruiseName": "7 Day Western Caribbean",
    "duration": 7,
    "ports": [
      {
        "day": 1,
        "name": "Port Canaveral",
        "arrival": null,
        "departure": "16:30",
        "pier": "CT-1"
      },
      ...
    ]
  },
  "lastScraped": "2025-11-13T12:00:00Z"
}
```

---

## 8. Technical Implementation

### 8.1 Architecture

**Pattern:** MVVM (Model-View-ViewModel) with Combine

```
PortPal/
├── App/
│   ├── PortPalApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── Ship.swift
│   ├── Cruise.swift
│   ├── Port.swift
│   ├── ShipPosition.swift
│   └── CruiseState.swift
├── ViewModels/
│   ├── CountdownViewModel.swift
│   ├── MapViewModel.swift
│   ├── ItineraryViewModel.swift
│   └── CruiseListViewModel.swift
├── Views/
│   ├── CountdownView.swift
│   ├── CountdownRing.swift
│   ├── MapView.swift
│   ├── ItineraryView.swift
│   ├── PortRow.swift
│   ├── CruiseCard.swift
│   └── SettingsView.swift
├── Services/
│   ├── AISService.swift
│   ├── NotificationService.swift
│   ├── DatabaseService.swift
│   ├── LocationService.swift
│   └── ScraperService.swift
├── Utilities/
│   ├── DateExtensions.swift
│   ├── ColorExtensions.swift
│   ├── TimerUtility.swift
│   └── HapticFeedback.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Ships.json
└── Tests/
    ├── UnitTests/
    └── UITests/
```

### 8.2 Key Components

**CountdownViewModel:**
```swift
@MainActor
class CountdownViewModel: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentPort: Port?
    @Published var urgencyState: UrgencyState = .allGood
    @Published var ringColor: Color = .green
    @Published var stateMessage: String = "Relax and Enjoy"
    
    private var timer: Timer?
    private let aisService: AISService
    private let notificationService: NotificationService
    
    func startCountdown(for cruise: Cruise) {
        // Calculate time to next port departure
        // Update every second
        // Manage urgency state transitions
        // Schedule notifications
    }
    
    func updateUrgencyState() {
        // Determine current urgency based on timeRemaining
        // Update UI colors and messages
        // Trigger haptics on state change
    }
    
    func fetchShipPosition() async {
        // Get real-time position from AIS
        // Update map view
    }
}
```

**AISService:**
```swift
actor AISService {
    private var webSocket: URLSessionWebSocketTask?
    private var positionCache: [String: ShipPosition] = [:]
    
    func connectToStream(mmsi: [String]) async throws {
        // Establish WebSocket connection to AISStream.io
        // Subscribe to specific MMSI numbers
        // Handle incoming position updates
    }
    
    func getPosition(for mmsi: String) async -> ShipPosition? {
        // Return cached position if recent (<15 min)
        // Otherwise fetch from API
    }
    
    func startPolling(mmsi: String, interval: TimeInterval) {
        // For background updates when WebSocket not active
    }
}
```

**NotificationService:**
```swift
class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    func scheduleNotifications(for cruise: Cruise) {
        // Calculate notification times for each port
        // Create UNNotificationRequest with appropriate urgency
        // Add action buttons
    }
    
    func sendCriticalAlert() {
        // Send critical interruption level notification
        // Bypass Do Not Disturb
        // Play custom sound
    }
    
    func updateLiveActivity(timeRemaining: TimeInterval, state: UrgencyState) {
        // Update Dynamic Island and Lock Screen widget
    }
}
```

### 8.3 State Management

**CruiseState Enum:**
```swift
enum CruiseState: String, Codable {
    case embarkationDay      // Before first sailing
    case settingSailSoon     // 6 hours before first port arrival
    case seasTheDay          // At sea between ports
    case landHo              // Approaching next port (1 hour before arrival)
    case explorationTime     // At port, countdown active
    case finalReturn         // Last day, returning home
    
    var emoji: String {
        switch self {
        case .embarkationDay: return "🎉"
        case .settingSailSoon: return "⚓"
        case .seasTheDay: return "🌊"
        case .landHo: return "🏝️"
        case .explorationTime: return "⏰"
        case .finalReturn: return "🏠"
        }
    }
    
    var message: String {
        switch self {
        case .embarkationDay: return "Welcome Aboard!"
        case .settingSailSoon: return "Setting Sail Soon"
        case .seasTheDay: return "Seas the Day"
        case .landHo: return "Land Ho!"
        case .explorationTime: return "Exploration Time"
        case .finalReturn: return "Thanks for Cruising"
        }
    }
}
```

**UrgencyState Enum:**
```swift
enum UrgencyState: String, Codable {
    case allGood             // 7+ hours
    case stayAlert           // 3-7 hours
    case departingSoon       // 1-3 hours
    case returnNow           // 45min-1hr
    case shipDeparted        // Past departure
    
    var color: Color {
        switch self {
        case .allGood: return Color(hex: "#00D4AA")
        case .stayAlert: return Color(hex: "#FFD54F")
        case .departingSoon: return Color(hex: "#FF6B35")
        case .returnNow: return Color(hex: "#FF1744")
        case .shipDeparted: return Color(hex: "#6B7280")
        }
    }
    
    var message: String {
        switch self {
        case .allGood: return "Relax and Enjoy"
        case .stayAlert: return "Stay Alert"
        case .departingSoon: return "Departing Soon"
        case .returnNow: return "Return to Ship NOW"
        case .shipDeparted: return "Ship Has Departed"
        }
    }
    
    var shouldPulse: Bool {
        return self == .returnNow
    }
}
```

### 8.4 Performance Optimizations

**Battery Management:**
- Use significant location changes instead of continuous GPS
- Reduce AIS polling frequency when backgrounded
- Pause animations when app not visible
- Use efficient Core Data fetch requests with predicates

**Memory Management:**
- Lazy load ship images with SDWebImage
- Cache only last 100 ship positions per MMSI
- Purge old cruise data after 6 months
- Use lightweight Core Data objects

**Network Efficiency:**
- Batch API requests where possible
- Implement exponential backoff for retries
- Cache cruise data for 24 hours
- Use conditional GET requests with ETags

---

## 9. Testing Strategy

### 9.1 Unit Tests

**Critical Components to Test:**
- Date/time calculations (timezone handling, embarkation date offsets)
- Urgency state transitions
- Countdown timer accuracy
- AIS data parsing
- Notification scheduling logic

**Test Cases:**
```swift
// Example: Urgency State Tests
func testUrgencyStateTransition_AllGoodToStayAlert() {
    let viewModel = CountdownViewModel()
    viewModel.timeRemaining = 6.5 * 3600  // 6.5 hours
    viewModel.updateUrgencyState()
    XCTAssertEqual(viewModel.urgencyState, .stayAlert)
}

func testCountdownAccuracy() {
    // Test countdown timer stays synchronized with real time
}

func testTimezoneHandling() {
    // Test port times calculated correctly across timezones
}
```

### 9.2 Integration Tests

- AIS WebSocket connection and reconnection
- Firebase Firestore sync
- Notification delivery and timing
- Live Activity updates
- Watch connectivity

### 9.3 UI Tests

- Countdown ring animations
- Swipe gestures between ports
- Map interactions
- Settings panel
- Onboarding flow

### 9.4 Real-World Testing

**Critical:** Test on actual cruises!
- Verify countdown accuracy while at port
- Test AIS tracking with real ship positions
- Validate notification timing
- Check battery usage over full cruise duration
- Test offline functionality when no WiFi

---

## 10. Security & Privacy

### 10.1 Data Privacy

**Principles:**
- Minimal data collection (only what's necessary for functionality)
- No personally identifiable information required
- Optional analytics with user consent
- Clear privacy policy

**Data Collected:**
- Selected cruise information (stored locally)
- Ship positions (cached temporarily)
- App usage analytics (optional, anonymized)

**Data NOT Collected:**
- Personal names, emails, phone numbers
- Payment information (subscription handled by Apple)
- Location data (only used for map centering, never stored)
- Contacts or photos

### 10.2 Security Measures

- All API communications over HTTPS
- API keys stored in iOS Keychain
- No sensitive data in UserDefaults
- Code obfuscation for release builds
- Regular security audits

### 10.3 Compliance

- GDPR compliant (EU users)
- CCPA compliant (California users)
- COPPA compliant (no data collection from users <13)
- Apple App Store privacy requirements

---

## 11. Monetization Strategy

### 11.1 Free Tier

**Features Included:**
- Full countdown timer for ONE active cruise
- Basic ship tracking (position updates every 5 minutes)
- Standard notifications
- Itinerary view
- Apple Watch sync

### 11.2 Premium Tier ($4.99/month or $29.99/year)

**Additional Features:**
- Unlimited active cruises
- Real-time ship tracking (30-second updates)
- Historical cruise tracking and stats
- Premium notifications (critical alerts)
- Advanced map features (ship trail, weather overlay)
- Priority support
- Early access to new features

### 11.3 Revenue Projections

**Year 1:**
- Total Downloads: 100,000
- Premium Conversion: 10% (10,000 users)
- Average Revenue Per User (ARPU): $36/year
- Gross Revenue: $360,000
- Apple's 30% Cut: -$108,000
- Net Revenue: $252,000

**Year 2:**
- Total Downloads: 300,000 (cumulative)
- Premium Users: 35,000
- Net Revenue: $882,000

### 11.4 Alternative Revenue

- Cruise line partnerships (featured listings)
- Port excursion affiliate commissions
- Premium ship photo packs
- Themed countdown ring designs

---

## 12. Marketing & Launch Strategy

### 12.1 Pre-Launch (Months 1-3)

**Goals:**
- Build anticipation
- Gather beta testers
- Refine product based on feedback

**Tactics:**
- Create landing page with email signup
- Reach out to cruise bloggers and YouTubers
- Post in cruise-related Facebook groups
- TestFlight beta with 100 users
- Social media teasers (Instagram, TikTok)

### 12.2 Launch (Month 4)

**Goals:**
- 10,000 downloads in first month
- App Store featuring
- Media coverage

**Tactics:**
- Press release to tech and travel media
- Product Hunt launch
- Cruise forum announcements (Cruise Critic, Reddit r/cruise)
- Influencer partnerships (micro-influencers with cruise focus)
- App Store optimization (ASO): keywords, screenshots, preview video
- Launch discount: 50% off premium for first month

### 12.3 Post-Launch Growth (Months 5-12)

**Goals:**
- Reach 100,000 downloads
- 10% premium conversion
- 4.8+ star rating

**Tactics:**
- User-generated content campaign (#NeverMissTheShip)
- Partnerships with cruise booking sites
- Seasonal promotions (Wave Season, Black Friday)
- Feature updates and blog posts
- Email marketing to free users
- App Store search ads
- Retargeting campaigns

### 12.4 Success Metrics

**Download Metrics:**
- Installs per day
- Install sources (organic vs. paid)
- App Store impressions and conversion rate

**Engagement Metrics:**
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- Session length
- Sessions per user
- Feature adoption rates

**Conversion Metrics:**
- Free to premium conversion rate
- Trial to paid conversion
- Churn rate
- Customer Lifetime Value (LTV)

**Quality Metrics:**
- App Store rating
- Review sentiment
- Crash rate
- Bug reports

---

## 13. Roadmap

### Phase 1: MVP (Months 1-3) ✅ COMPLETE

- [x] Core countdown timer
- [x] Basic ship database (Caribbean cruises)
- [x] Visual design (ocean gradient, countdown ring)
- [x] Itinerary list view
- [x] Settings panel
- [x] Urgency-based color states

### Phase 2: Enhanced Tracking (Months 4-6) 🔄 IN PROGRESS

- [ ] AIS integration (AISStream.io)
- [ ] Real-time ship position on map
- [ ] CruiseMapper scraper
- [ ] Expanded database (North America, Central America)
- [ ] Push notifications
- [ ] TestFlight beta launch

### Phase 3: Polish & Launch (Months 7-9)

- [ ] Live Activities and Dynamic Island
- [ ] Apple Watch app and complications
- [ ] Onboarding flow
- [ ] App Store optimization
- [ ] Public launch
- [ ] Marketing campaign

### Phase 4: Premium Features (Months 10-12)

- [ ] Premium subscription implementation
- [ ] Historical cruise stats
- [ ] Ship trail on map
- [ ] Weather overlay
- [ ] Port excursion suggestions
- [ ] Multiple cruise support

### Phase 5: Global Expansion (Year 2)

- [ ] Mediterranean routes
- [ ] European rivers
- [ ] Asia-Pacific routes
- [ ] South America routes
- [ ] Antarctica expeditions
- [ ] Localization (Spanish, French, German, Italian)

### Phase 6: Advanced Features (Year 2+)

- [ ] Augmented Reality ship finder
- [ ] Social features (find friends on your cruise)
- [ ] Port reviews and recommendations
- [ ] Integration with cruise line apps
- [ ] Offline maps
- [ ] Widget customization
- [ ] iPad optimization
- [ ] macOS app

---

## 14. Risk Management

### 14.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| AIS data unavailable/unreliable | Medium | High | Multiple data source fallbacks, cached data, continue countdown without position |
| API rate limits exceeded | Medium | Medium | Implement intelligent caching, reduce polling frequency, upgrade API tier |
| Battery drain complaints | Medium | High | Optimize background tasks, provide battery saver mode, educate users |
| Notification delivery failures | Low | High | Use multiple notification methods, test thoroughly, provide in-app alerts |
| Time zone calculation errors | Medium | Critical | Extensive testing, use trusted time zone libraries, user feedback system |

### 14.2 Business Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Low user adoption | Medium | Critical | Aggressive marketing, partnerships, excellent UX, solve real pain point |
| Poor premium conversion | Medium | High | Value demonstration, free trial, competitive pricing, compelling features |
| Cruise line legal issues | Low | High | Legal review, don't imply endorsement, clear disclaimer, public data only |
| Competitor launches similar app | Medium | Medium | First-mover advantage, superior design, cruise-specific focus |
| Database maintenance burden | High | Medium | Automate scraping, community contributions, partnerships with cruise lines |

### 14.3 Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Server costs exceed revenue | Medium | High | Efficient architecture, caching strategy, premium tier pricing |
| Cannot scale customer support | Medium | Medium | Comprehensive FAQ, in-app help, automated responses, hire as needed |
| Data quality issues | High | Medium | Crowdsourced corrections, verification system, regular audits |
| Developer burnout | Medium | High | Reasonable scope, focus on core features, potential co-founder/team |

---

## 15. Success Criteria

### 15.1 Launch Success (First 90 Days)

- ✅ **10,000 downloads** in first month
- ✅ **4.5+ star rating** on App Store
- ✅ **70%+ Day 1 retention**
- ✅ **5%+ free to premium conversion**
- ✅ **< 1% crash rate**
- ✅ **Featured by Apple** in "New Apps We Love" or similar

### 15.2 Year 1 Success

- ✅ **100,000 total downloads**
- ✅ **10,000 premium subscribers**
- ✅ **4.8+ star rating**
- ✅ **$250,000+ net revenue**
- ✅ **60%+ annual retention**
- ✅ **Top 10 in Travel category**

### 15.3 User Satisfaction

- ✅ **95%+ accuracy** in countdown timing
- ✅ **< 5 seconds** app launch time
- ✅ **< 2% support ticket rate**
- ✅ **80%+ users recommend** to fellow cruisers
- ✅ **Net Promoter Score (NPS) > 50**

---

## 16. Appendices

### Appendix A: Competitive Analysis

| App | Pros | Cons | Differentiation |
|-----|------|------|-----------------|
| **Cruise Ship Mate** | Large user base, social features | Cluttered UI, not focused on timers | PortPal is timer-focused with cleaner design |
| **CruiseMapper** | Comprehensive ship database | Not a mobile app, no countdown feature | PortPal is native mobile with countdown |
| **Flighty** (flights) | Beautiful design, excellent UX | Not for cruises | PortPal applies Flighty's excellence to cruises |
| **Ship Finder** | Good ship tracking | Not cruise-specific, complex | PortPal is simplified for cruise passengers |

### Appendix B: User Feedback (Beta)

**Most Requested Features:**
1. More cruise lines and routes
2. Offline mode for no WiFi at sea
3. Share itinerary with travel companions
4. Port excursion timer (return to meeting point)
5. Countdown to embarkation day

**Common Complaints:**
1. Occasional state calculation errors (FIXED)
2. Want more customization options
3. Battery usage higher than expected (OPTIMIZING)

### Appendix C: Technical Specifications

**Minimum Requirements:**
- iOS 18.0+
- iPhone 12 or newer
- 100 MB storage
- Internet connection required for initial setup and ship tracking

**Recommended:**
- iOS 18.2+
- iPhone 14 Pro or newer (for Dynamic Island)
- Apple Watch Series 6 or newer
- Cellular + GPS model for offshore tracking

**Supported Devices:**
- iPhone: All models iPhone 12 and newer
- iPad: iPad Air 4th gen and newer, iPad Pro 3rd gen and newer
- Apple Watch: Series 6 and newer
- Mac: Apple Silicon Macs with macOS 14+ (future)

### Appendix D: Glossary

- **AIS (Automatic Identification System):** Maritime tracking system that transmits ship position, heading, and speed
- **MMSI (Maritime Mobile Service Identity):** Unique 9-digit identifier for ships
- **Embarkation:** Boarding the cruise ship at the start of the cruise
- **Disembarkation:** Leaving the cruise ship at the end of the cruise
- **Port of Call:** Destination where the ship stops during the cruise
- **Sea Day:** Day spent entirely at sea with no port stops
- **Tender:** Small boat used to transport passengers from ship to shore when ship can't dock
- **All Aboard Time:** Time by which all passengers must be back on the ship
- **Gross Tonnage (GT):** Measure of ship's internal volume
- **Pier/Terminal:** Specific docking location at a port

---

## 17. Contact & Support

**Project Owner:** Josh  
**Development Start:** Q3 2024  
**Target Launch:** Q2 2025  

**Documentation Updates:**
This PRD is a living document and will be updated as the product evolves. All changes should be documented with version numbers and dates.

**Feedback:**
For product feedback, feature requests, or bug reports during development, please contact the development team.

---

**Document Version History:**

- **v1.0** (Aug 2024): Initial PRD
- **v1.5** (Oct 2024): Added MVP completion notes, real-world testing insights
- **v2.0** (Nov 2024): Complete redesign based on Flighty inspiration, comprehensive UI/UX specifications, AIS integration details, updated roadmap

---

*End of Product Requirements Document*
