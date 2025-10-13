import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showCreateModal = false
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeTab()
                    .tag(0)
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            if selectedTab == 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showCreateModal = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.5), radius: 12, x: 0, y: 6)
                        }
                        .padding(24)
                    }
                }
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showCreateModal) {
            CreateTimerSheet(isPresented: $showCreateModal)
        }
        .onAppear {
            if timerManager.timers.isEmpty {
                showCreateModal = true
            }
        }
    }
}
