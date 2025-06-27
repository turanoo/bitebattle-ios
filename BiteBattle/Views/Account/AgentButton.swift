//
//  AgentButton.swift
//  BiteBattle
//

import SwiftUI

struct AgentButton: View {
    var body: some View {
        NavigationLink(value: Route.account) {
            HStack(spacing: 6) {
                Image(systemName: "message")
                    .foregroundColor(AppColors.textOnPrimary)
                Text("AI")
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
struct NavToolItem: Identifiable {
  let id = UUID()
  let systemImage: String
  let label: String
  let destination: Route
}

struct VerticalToolbarView: View {
    let items: [NavToolItem]
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            ForEach(items) { item in
                NavigationLink(value: item.destination) {
                    HStack {
                        Image(systemName: item.systemImage)
                            .foregroundColor(AppColors.textOnPrimary)
                        Text(item.label)
                            .foregroundColor(AppColors.textOnPrimary)
                    }
                    //.frame(minWidth: 75, maxWidth: .infinity, maxHeight: 24)
                    .frame(maxHeight: 24)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(AppColors.primary.opacity(0.9))
                    .cornerRadius(10)
                }
            }
        }
        .frame(alignment: .trailing)
    }
}
    
    

#Preview {
    AgentButton()
}
