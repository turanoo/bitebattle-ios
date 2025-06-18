//
//  AccountViewModel.swift
//  BiteBattle
//

import Foundation
import SwiftUI
import PhotosUI

class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var newPassword: String = ""
    @Published var statusMessage: String?
    @Published var isLoading: Bool = false
    @Published var originalName: String = ""
    @Published var originalEmail: String = ""
    @Published var fetchFailed: Bool = false
    @Published var showCheckmark: Bool = false
    @Published var keyboardHeight: CGFloat = 0
    @Published var profileImage: Image?
    @Published var selectedItem: PhotosPickerItem? {
        didSet{ Task { try await loadImage()} }
    }
    
    func fetchAccount() {
        self.isLoading = true
        self.fetchFailed = false
        APIClient.shared.fetchAccount { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let account):
                    // Only update the originals, not the text field bindings, to keep fields editable
                    if self.name.isEmpty { self.name = account.name }
                    if self.email.isEmpty { self.email = account.email }
                    self.originalName = account.name
                    self.originalEmail = account.email
                case .failure(let error):
                    self.statusMessage = error.localizedDescription
                    self.fetchFailed = true
                }
            }
        }
    }
    
    
    
    func loadImage() async throws{
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        self.profileImage = Image(uiImage: uiImage)
    }
    
    func updateAccount(clearFocus: @escaping () -> Void) {
        self.isLoading = true
        self.statusMessage = nil
        let lowercasedEmail = email.lowercased()
        APIClient.shared.updateAccount(name: name, email: lowercasedEmail, currentPassword: password, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.password = ""
                    self.newPassword = ""
                    clearFocus()
                    self.showCheckmark = true
                    withAnimation {
                        self.showCheckmark = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            self.showCheckmark = false
                        }
                    }
                    self.fetchAccount()
                case .failure(let error):
                    if let apiError = error as? APIClient.APIError, case .unauthorized(let message) = apiError {
                        self.statusMessage = message
                    } else {
                        self.statusMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    var fieldsChanged: Bool {
            name != originalName || email != originalEmail || !password.isEmpty || !newPassword.isEmpty
        }
    
}
