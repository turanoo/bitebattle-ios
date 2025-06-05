import SwiftUI

// MARK: - Ensure AppColors, AppButton, AppBackground are visible
// If you get 'Cannot find ... in scope', ensure these files are in the Compile Sources build phase in Xcode.
// No extra import is needed if they're in the same target.

struct LandingView: View {
    @State private var showRegister = false
    @State private var showLogin = false
    var body: some View {
        AppBackground {
            VStack(spacing: 32) {
                Spacer()
                // Logo (match HomeView)
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(AppColors.orange)
                    .shadow(radius: 10)

                Text("Welcome to BiteBattle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.orange)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 4)

                VStack(spacing: 18) {
                    NavigationLink(destination: RegisterView(), isActive: $showRegister) {
                        AppButton(title: "Register", icon: nil, background: AppColors.brown.opacity(0.9), foreground: AppColors.orange, isLoading: false, isDisabled: false) {
                            showRegister = true
                        }
                    }
                    NavigationLink(destination: LoginView(), isActive: $showLogin) {
                        AppButton(title: "Login", icon: nil, background: AppColors.orange.opacity(0.8), foreground: AppColors.textOnPrimary, isLoading: false, isDisabled: false) {
                            showLogin = true
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
}

#if DEBUG
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
#endif
