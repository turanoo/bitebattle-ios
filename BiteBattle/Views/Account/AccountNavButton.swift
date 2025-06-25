import SwiftUI
import Foundation


struct AccountNavButton: View {
    var body: some View {
        NavigationLink(value: Route.account) {
            HStack(spacing: 6) {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(AppColors.textOnPrimary)
                Text("Account")
                    .foregroundColor(AppColors.textOnPrimary)
            }
            .frame(maxHeight: 24)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(AppColors.primary.opacity(0.9))
            .cornerRadius(10)
        }
    }
}
