import SwiftUI

// Explicitly import project files for cross-file visibility
// These are not modules, so use @testable import or move shared types to a shared module if needed
// For now, add file-level import for clarity
// import AppBackground // Not needed, just ensure file is in Compile Sources
// import AppColors // Not needed, just ensure file is in Compile Sources
// import AppTextField // Not needed, just ensure file is in Compile Sources
// import AppButton // Not needed, just ensure file is in Compile Sources
// import APIClient // Not needed, just ensure file is in Compile Sources

struct AccountView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var newPassword: String = ""
    @State private var statusMessage: String?
    @State private var isLoading: Bool = false
    @State private var originalName: String = ""
    @State private var originalEmail: String = ""
    @State private var fetchFailed: Bool = false
    @State private var showCheckmark: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name, email, password, newPassword
    }

    var body: some View {
        AppBackground {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    if showCheckmark {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(AppColors.accent)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.top, 8)
                    }

                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(AppColors.primary)
                        .shadow(radius: 8)

                    Text("Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                        .shadow(radius: 4)

                    VStack(spacing: 18) {
                        AppTextField(placeholder: "Name", text: $name, icon: "person")
                            .focused($focusedField, equals: .name)
                        AppTextField(placeholder: "Email", text: $email, icon: "envelope")
                            .focused($focusedField, equals: .email)
                        AppTextField(placeholder: "Current Password (optional)", text: $password, isSecure: true, icon: "lock")
                            .focused($focusedField, equals: .password)
                        AppTextField(placeholder: "New Password (optional)", text: $newPassword, isSecure: true, icon: "lock.rotation")
                            .focused($focusedField, equals: .newPassword)
                    }
                    .padding(.horizontal, 0)

                    if let status = statusMessage {
                        Text(status)
                            .foregroundColor(AppColors.error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    AppButton(title: isLoading ? "Updating..." : "Update", icon: "checkmark.circle", background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: isLoading, isDisabled: !fieldsChanged || isLoading || (!password.isEmpty && newPassword.isEmpty) || (password.isEmpty && !newPassword.isEmpty)) {
                        updateAccount()
                    }
                    .padding(.horizontal, 0)

                    Spacer(minLength: 0)
                }
                .padding()
                .padding(.bottom, keyboardHeight)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isLoggedIn = false }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(AppColors.error)
                            Text("Sign Out")
                                .foregroundColor(AppColors.error)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(AppColors.surface)
                        .cornerRadius(10)
                    }
                }
            }
            .onAppear {
                fetchAccount()
                subscribeToKeyboardNotifications()
            }
            .onDisappear {
                unsubscribeFromKeyboardNotifications()
            }
        }
    }

    private var fieldsChanged: Bool {
        name != originalName || email != originalEmail || !password.isEmpty || !newPassword.isEmpty
    }

    func fetchAccount() {
        isLoading = true
        fetchFailed = false
        APIClient.shared.fetchAccount { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let account):
                    // Only update the originals, not the text field bindings, to keep fields editable
                    if name.isEmpty { name = account.name }
                    if email.isEmpty { email = account.email }
                    originalName = account.name
                    originalEmail = account.email
                case .failure(let error):
                    statusMessage = error.localizedDescription
                    fetchFailed = true
                }
            }
        }
    }

    func updateAccount() {
        isLoading = true
        statusMessage = nil
        let lowercasedEmail = email.lowercased()
        APIClient.shared.updateAccount(name: name, email: lowercasedEmail, currentPassword: password, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    password = ""
                    newPassword = ""
                    focusedField = nil // Remove focus from all fields
                    showCheckmark = true
                    withAnimation {
                        showCheckmark = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            showCheckmark = false
                        }
                    }
                    fetchAccount()
                case .failure(let error):
                    if let apiError = error as? APIClient.APIError, case .unauthorized(let message) = apiError {
                        statusMessage = message
                    } else {
                        statusMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    // Keyboard handling
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation { keyboardHeight = frame.height - (UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.windows.first }.first?.safeAreaInsets.bottom ?? 0) }
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation { keyboardHeight = 0 }
        }
    }
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
