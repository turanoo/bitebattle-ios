import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppBackground {
                VStack(spacing: 32) {
                    Spacer()
                    // Logo
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(AppColors.primary)
                        .shadow(radius: 10)

                    VStack(spacing: 18) {
                        NavigationLink(value: Route.poll) {
                            AppButtonLabel(
                                title: "Polls",
                                icon: nil,
                                background: AppColors.primary,
                                foreground: AppColors.textOnPrimary,
                                isLoading: false,
                                isDisabled: false
                            )
                        }
                        NavigationLink(value: Route.headToHead) {
                            AppButtonLabel(
                                title: "Head-to-Head",
                                icon: nil,
                                background: AppColors.secondary,
                                foreground: AppColors.textOnPrimary,
                                isLoading: false,
                                isDisabled: false
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding()
                .background(AppColors.background.ignoresSafeArea())
            }
            VerticalToolbarView(items: [NavToolItem(systemImage: "person.crop.circle", label: "Account", destination: Route.account), NavToolItem(systemImage: "message", label: "AI", destination: Route.account)])
                .padding(.trailing, 12)
                .padding(.top, 6)
        }
       
    }
}


struct AppButtonLabel: View {
    let title: String
    let icon: String?
    let background: Color
    let foreground: Color
    let isLoading: Bool
    let isDisabled: Bool

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(foreground)
            }
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: foreground))
            } else {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(foreground)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, 2)
        .background(isDisabled ? AppColors.disabled : background)
        .cornerRadius(12)
        .shadow(color: background.opacity(0.15), radius: 2, x: 0, y: 1)
        .scaleEffect(isDisabled ? 1.0 : 0.98, anchor: .center)
        .animation(.easeInOut(duration: 0.15), value: isDisabled)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(path: .constant(NavigationPath()))
    }
}
#endif
