//
//  Untitled.swift
//  BiteBattle
//

import SwiftUI

struct AIHomeView: View {
    @Binding var path: NavigationPath
    @State var command: String = ""
    @State var disableSubmit: Bool = true
    @State private var showHelp = false
    @State var takeMeThere = false
    @State var failure = false
    
    var body: some View {
        AppBackground {
            VStack(spacing: 20) {
                Text("BiteBattle AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .shadow(radius: 2)
                    .padding(.top, 24)
                AppTextField(placeholder: "Ask me to make you a poll!", text: $command)
                AppButton(title: "Submit", icon: "", background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: false, isDisabled: command.isEmpty) {
                    submitRequest()
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showHelp = true }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .alert("AI Help", isPresented: $showHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Type in what you want to create (either a poll or head to head), what types of food you are looking for, and your location.")
            }
            .alert("Take Me There", isPresented: $takeMeThere) {
                Button("Stay here", role: .cancel) { }
                NavigationLink(value: Route.poll) {
                    Button("Take me there") { }
                }
            } message: {
                Text("Go to your created item?")
            }
            .alert("Failure", isPresented: $failure) {
                Button("Try again?") { submitRequest() }
                Button("OK", role: .cancel) { }
            } message: {
                Text("AI has failed to create your poll. Please try again later")
            }
        }
        .hideKeyboardOnTap()
        
    }
    
    func submitRequest() {
        guard !command.isEmpty else { return }
        
        
        APIClient.shared.useAiPoll(command: command) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("successfully created AI poll view")
                    takeMeThere = true
                    //isCreatingPoll = false
                    // After creation, ask user if they want to navigate to that poll?
                    //fetchPolls()
                case .failure(let error):
                    //isCreatingPoll = false
                    failure = true
                    //takeMeThere = true
                    print(error.localizedDescription)
                    //statusMessage = error.localizedDescription
                }
            }
        }
        
    }
    
}

