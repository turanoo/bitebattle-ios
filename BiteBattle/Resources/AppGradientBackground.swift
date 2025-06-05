// AppGradientBackground.swift
// Reusable gradient background for BiteBattle
import SwiftUI

public struct AppGradientBackground<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [AppColors.primary.opacity(0.12), AppColors.secondary.opacity(0.18)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            content
        }
    }
}
