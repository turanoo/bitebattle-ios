// AppColors.swift
// Centralized color palette for BiteBattle
import SwiftUI

// Ensure all properties and struct are public for cross-file access
public struct AppColors {
    // Modern, accessible palette
    public static let primary      = Color(hex: "#2563eb") // Blue 600
    public static let secondary    = Color(hex: "#f59e42") // Orange 400
    public static let background   = Color(hex: "#f8fafc") // Gray 50
    public static let surface      = Color(hex: "#ffffff") // White
    public static let accent       = Color(hex: "#10b981") // Emerald 500
    public static let error        = Color(hex: "#ef4444") // Red 500
    public static let border       = Color(hex: "#e2e8f0") // Gray 200

    // Text
    public static let textPrimary    = Color(hex: "#1e293b") // Gray 800
    public static let textSecondary  = Color(hex: "#64748b") // Gray 500
    public static let textOnPrimary  = Color.white
    public static let textOnSecondary = Color.white

    // UI States
    public static let tileBackground = Color(hex: "#f1f5f9") // Gray 100
    public static let tileSelected   = primary.opacity(0.10)
    public static let disabled       = Color(hex: "#cbd5e1") // Gray 300

    // Legacy color aliases for compatibility
    public static let orange = primary
    public static let brown = secondary
}

// Helper to use hex colors
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
