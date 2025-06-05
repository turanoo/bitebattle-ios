import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var registrationStatus: String?
    @State private var isLoading = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Environment(\.presentationMode) var presentationMode

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

                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                    .shadow(radius: 3)

                VStack(spacing: 16) {
                    AppTextField(placeholder: "Full Name", text: $name, icon: "person")
                    AppTextField(placeholder: "Email", text: $email, icon: "envelope")
                    AppTextField(placeholder: "Password", text: $password, isSecure: true, icon: "lock")
                }
                .padding(.horizontal, 24)

                AppButton(title: isLoading ? "Registering..." : "Register", icon: nil, background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: isLoading, isDisabled: isLoading) {
                    registerUser()
                }
                .padding(.horizontal, 24)

                if let status = registrationStatus {
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

    func registerUser() {
        isLoading = true
        registrationStatus = nil
        let lowercasedEmail = email.lowercased()
        APIClient.shared.register(email: lowercasedEmail, password: password, name: name) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "authToken")
                    isLoggedIn = true
                    registrationStatus = "Successfully registered!"
                case .failure(let error):
                    registrationStatus = "Failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
#endif
