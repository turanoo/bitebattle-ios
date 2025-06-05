// AppButton.swift
// Minimalistic, consistent button for BiteBattle
import SwiftUI



public struct AppButton: View {
    let title: String
    let icon: String?
    let background: Color
    let foreground: Color
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(title: String, icon: String? = nil, background: Color = AppColors.primary, foreground: Color = AppColors.textOnPrimary, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.background = background
        self.foreground = foreground
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.textOnPrimary)
                }
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textOnPrimary))
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textOnPrimary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.vertical, 2)
            .background(isDisabled ? AppColors.disabled : background)
            .cornerRadius(14)
            .shadow(color: background.opacity(0.12), radius: 3, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .scaleEffect(isDisabled ? 1.0 : 0.98, anchor: .center)
            .animation(.easeInOut(duration: 0.15), value: isDisabled)
        }
        .disabled(isDisabled || isLoading)
    }
}
