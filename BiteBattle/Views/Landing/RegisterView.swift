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
            ZStack {
                // Modern background
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
    }

    func registerUser() {
        guard let url = URL(string: Endpoints.register) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "email": email,
            "password": password,
            "name": name
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else { return }

        request.httpBody = httpBody

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    registrationStatus = "Failed: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        // Parse token from response data
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let token = json["token"] as? String {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            isLoggedIn = true // Trigger navigation to HomeView
                            registrationStatus = "Successfully registered!"
                        } else {
                            registrationStatus = "Registration succeeded, but token missing."
                        }
                    } else {
                        registrationStatus = "Failed: Status \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
#endif
