import SwiftUI
import Foundation

struct AnimatedOceanGradient: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                // Static gradient when Reduce Motion is enabled
                staticGradient
            } else {
                // Animated gradient when motion is allowed
                animatedGradient
            }
        }
    }

    private var staticGradient: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    getBaseColor1(time: 0),
                    getBaseColor2(time: 0),
                    getBaseColor3(time: 0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var animatedGradient: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                // Layer 1 - Base ocean gradient with subtle color cycling
                LinearGradient(
                    gradient: Gradient(colors: [
                        getBaseColor1(time: time),
                        getBaseColor2(time: time),
                        getBaseColor3(time: time)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Layer 2 - Overlay with different timing
                LinearGradient(
                    gradient: Gradient(colors: [
                        getAccentColor1(time: time),
                        getAccentColor2(time: time),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.5)

                // Layer 3 - Moving radial gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        getShimmerColor(time: time),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 50,
                    endRadius: 600
                )
                .opacity(0.3)
            }
        }
    }
    
    private func getBaseColor1(time: TimeInterval) -> Color {
        let cycle = sin(time * 0.15) * 0.5 + 0.5
        
        if colorScheme == .dark {
            return Color(
                red: 0.02 + cycle * 0.06,
                green: 0.08 + cycle * 0.08,
                blue: 0.15 + cycle * 0.10
            )
        } else {
            return Color(
                red: 0.90 + cycle * 0.08,
                green: 0.95 + cycle * 0.04,
                blue: 0.98 + cycle * 0.02
            )
        }
    }
    
    private func getBaseColor2(time: TimeInterval) -> Color {
        let cycle = sin(time * 0.12 + 2) * 0.5 + 0.5
        
        if colorScheme == .dark {
            return Color(
                red: 0.03 + cycle * 0.07,
                green: 0.10 + cycle * 0.10,
                blue: 0.20 + cycle * 0.12
            )
        } else {
            return Color(
                red: 0.85 + cycle * 0.10,
                green: 0.92 + cycle * 0.06,
                blue: 0.96 + cycle * 0.03
            )
        }
    }
    
    private func getBaseColor3(time: TimeInterval) -> Color {
        let cycle = sin(time * 0.18 + 4) * 0.5 + 0.5
        
        if colorScheme == .dark {
            return Color(
                red: 0.01 + cycle * 0.05,
                green: 0.06 + cycle * 0.08,
                blue: 0.12 + cycle * 0.10
            )
        } else {
            return Color(
                red: 0.88 + cycle * 0.09,
                green: 0.94 + cycle * 0.05,
                blue: 0.99 + cycle * 0.01
            )
        }
    }
    
    private func getAccentColor1(time: TimeInterval) -> Color {
        let cycle = sin(time * 0.14) * 0.5 + 0.5
        
        if colorScheme == .dark {
            return Color(
                red: 0.04 + cycle * 0.08,
                green: 0.12 + cycle * 0.10,
                blue: 0.22 + cycle * 0.12
            )
        } else {
            return Color(
                red: 0.82 + cycle * 0.12,
                green: 0.90 + cycle * 0.08,
                blue: 0.95 + cycle * 0.04
            )
        }
    }
    
    private func getAccentColor2(time: TimeInterval) -> Color {
        let cycle = sin(time * 0.16 + 1.5) * 0.5 + 0.5
        
        if colorScheme == .dark {
            return Color(
                red: 0.02 + cycle * 0.06,
                green: 0.09 + cycle * 0.09,
                blue: 0.18 + cycle * 0.11
            )
        } else {
            return Color(
                red: 0.86 + cycle * 0.10,
                green: 0.93 + cycle * 0.06,
                blue: 0.97 + cycle * 0.02
            )
        }
    }
    
    private func getShimmerColor(time: TimeInterval) -> Color {
        let cycle = sin(time * 0.13) * 0.5 + 0.5
        
        if colorScheme == .dark {
            return Color(
                red: 0.05 + cycle * 0.10,
                green: 0.15 + cycle * 0.12,
                blue: 0.25 + cycle * 0.15
            )
        } else {
            return Color(
                red: 0.80 + cycle * 0.15,
                green: 0.88 + cycle * 0.10,
                blue: 0.94 + cycle * 0.05
            )
        }
    }
}
