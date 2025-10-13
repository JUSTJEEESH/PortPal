import SwiftUI

struct GlassEffect: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.15
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.white.opacity(opacity)
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .background(.ultraThinMaterial)
                .cornerRadius(cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

extension View {
    func glassEffect(cornerRadius: CGFloat = 20, opacity: Double = 0.15) -> some View {
        modifier(GlassEffect(cornerRadius: cornerRadius, opacity: opacity))
    }
}
