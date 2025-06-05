import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginStatus: String?
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some View {
        AppBackground {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                // Logo
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(AppColors.primary)
                    .shadow(radius: 8)

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                    .shadow(radius: 3)

                VStack(spacing: 16) {
                    AppTextField(placeholder: "Email", text: $email, icon: "envelope")
                    AppTextField(placeholder: "Password", text: $password, isSecure: true, icon: "lock")
                }
                .padding(.horizontal, 24)

                AppButton(title: isLoading ? "Logging in..." : "Login", icon: nil, background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: isLoading, isDisabled: isLoading) {
                    loginUser()
                }
                .padding(.horizontal, 24)

                if let status = loginStatus {
                    Text(status)
                        .foregroundColor(AppColors.error)
                        .font(.footnote)
                        .padding(.top, 8)
                        .shadow(radius: 1)
                }

                Spacer()
            }
            .padding()
        }
    }

    func loginUser() {
        isLoading = true
        loginStatus = nil
        let lowercasedEmail = email.lowercased()
        APIClient.shared.login(email: lowercasedEmail, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "authToken")
                    isLoggedIn = true
                    loginStatus = "Logged in!"
                case .failure(let error):
                    loginStatus = "Failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
