import SwiftUI

@main
struct PortPalApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var timerManager = TimerManager()
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        // Register notification categories on app launch
        NotificationManager.shared.registerNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(timerManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(nil)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
