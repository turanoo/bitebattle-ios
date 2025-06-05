// AppTextField.swift
// Minimalistic, consistent text field for BiteBattle
import SwiftUI
import Foundation

public struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String? = nil

    public var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(AppColors.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: AppColors.primary.opacity(0.04), radius: 1, x: 0, y: 1)
    }
}
