import SwiftUI

struct AccountView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var statusMessage: String?
    @State private var isLoading: Bool = false

    @State private var originalName: String = ""
    @State private var originalEmail: String = ""
    @State private var fetchFailed: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some View {
        AppGradientBackground {
            AppBackground {
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(AppColors.orange)
                        .shadow(radius: 8)

                    Text("Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textOnPrimary)
                        .shadow(radius: 4)

                    VStack(spacing: 18) {
                        AppTextField(placeholder: "Name", text: $name, icon: "person")
                        AppTextField(placeholder: "Email", text: $email, icon: "envelope")
                        AppTextField(placeholder: "Password", text: $password, isSecure: true, icon: "lock")
                    }
                    .padding(.horizontal, 0)

                    if let status = statusMessage {
                        Text(status)
                            .foregroundColor(AppColors.error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    AppButton(title: isLoading ? "Updating..." : "Update", icon: "checkmark.circle", background: AppColors.orange, foreground: AppColors.textOnPrimary, isLoading: isLoading, isDisabled: !fieldsChanged || isLoading) {
                        updateAccount()
                    }
                    .padding(.horizontal, 0)

                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isLoggedIn = false }) {
                            HStack(spacing: 6) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(AppColors.error)
                                Text("Sign Out")
                                    .foregroundColor(AppColors.error)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(AppColors.surface.opacity(0.7))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchAccount)
    }

    private var fieldsChanged: Bool {
        name != originalName || email != originalEmail || !password.isEmpty
    }

    private func getAuthToken() -> String? {
        let token = UserDefaults.standard.string(forKey: "authToken")
        return token?.isEmpty == false ? token : nil
    }

    func fetchAccount() {
        guard let token = getAuthToken(),
              let url = URL(string: Endpoints.account) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isLoading = true
        fetchFailed = false
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    statusMessage = error.localizedDescription
                    fetchFailed = true
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    statusMessage = "Failed to load account."
                    fetchFailed = true
                    return
                }
                name = json["name"] as? String ?? ""
                email = json["email"] as? String ?? ""
                originalName = name
                originalEmail = email
            }
        }.resume()
    }

    func updateAccount() {
        guard let token = getAuthToken(),
              let url = URL(string: Endpoints.account) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var payload: [String: String] = [
            "name": name,
            "email": email
        ]
        if !password.isEmpty {
            payload["password"] = password
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else { return }
        request.httpBody = httpBody

        isLoading = true
        statusMessage = nil
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    statusMessage = error.localizedDescription
                    return
                }
                statusMessage = "Account updated!"
                password = ""
                originalName = name
                originalEmail = email
            }
        }.resume()
    }
}


struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
