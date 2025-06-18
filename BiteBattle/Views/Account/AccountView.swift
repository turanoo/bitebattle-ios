import SwiftUI
import PhotosUI

// Explicitly import project files for cross-file visibility
// These are not modules, so use @testable import or move shared types to a shared module if needed
// For now, add file-level import for clarity
// import AppBackground // Not needed, just ensure file is in Compile Sources
// import AppColors // Not needed, just ensure file is in Compile Sources
// import AppTextField // Not needed, just ensure file is in Compile Sources
// import AppButton // Not needed, just ensure file is in Compile Sources
// import APIClient // Not needed, just ensure file is in Compile Sources

struct AccountView: View {
    @Binding var path: NavigationPath
    @StateObject var viewModel = ProfileViewModel()
    @State private var keyboardHeight: CGFloat = 0
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    enum Field: Hashable {
        case name, email, password, newPassword
    }

    var body: some View {
        AppBackground {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.showCheckmark {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(AppColors.accent)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.top, 8)
                    }

                    Spacer()
                    PhotosPicker(selection: $viewModel.selectedItem) {
                        if let profileImage = viewModel.profileImage {
                            profileImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        }
                        else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(AppColors.primary)
                                .shadow(radius: 8)
                        }
                    }
                   

                    Text("Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                        .shadow(radius: 4)

                    VStack(spacing: 18) {
                        AppTextField(placeholder: "Name", text: $viewModel.name, icon: "person")
                            .focused($focusedField, equals: .name)
                        AppTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope")
                            .focused($focusedField, equals: .email)
                        AppTextField(placeholder: "Current Password (optional)", text: $viewModel.password, isSecure: true, icon: "lock")
                            .focused($focusedField, equals: .password)
                        AppTextField(placeholder: "New Password (optional)", text: $viewModel.newPassword, isSecure: true, icon: "lock.rotation")
                            .focused($focusedField, equals: .newPassword)
                    }
                    .padding(.horizontal, 0)

                    if let status = viewModel.statusMessage {
                        Text(status)
                            .foregroundColor(AppColors.error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    AppButton(title: viewModel.isLoading ? "Updating..." : "Update", icon: "checkmark.circle", background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: viewModel.isLoading, isDisabled: !viewModel.fieldsChanged || viewModel.isLoading || (!viewModel.password.isEmpty && viewModel.newPassword.isEmpty) || (viewModel.password.isEmpty && !viewModel.newPassword.isEmpty)) {
                        viewModel.updateAccount{
                            focusedField = nil
                        }
                    }
                    .padding(.horizontal, 0)

                    Spacer(minLength: 0)
                }
                .padding()
                .padding(.bottom, keyboardHeight)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isLoggedIn = false
                        path.removeLast(path.count)
                    }) {
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
            .hideKeyboardOnTap()
            .onAppear {
                viewModel.fetchAccount()
                subscribeToKeyboardNotifications()
            }
            .onDisappear {
                unsubscribeFromKeyboardNotifications()
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
        AccountView(path: .constant(NavigationPath()))
    }
}
