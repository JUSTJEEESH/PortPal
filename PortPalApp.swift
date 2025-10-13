import SwiftUI

@main
struct PortPalApp: App {
    @StateObject private var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
                .preferredColorScheme(nil)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
