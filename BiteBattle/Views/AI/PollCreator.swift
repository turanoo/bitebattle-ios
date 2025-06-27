//
//  Untitled.swift
//  BiteBattle
//

import SwiftUI

struct AIHomeView: View {
    @Binding var path: NavigationPath
    @State var command: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            //maybe add a ? mark button for help
            AppTextField(placeholder: "What kind of food do you want and where are you", text: $command)
            Button("Submit Button"){
                submitRequest()
            }

        }
        
    }
    
    func submitRequest() {
        guard !command.isEmpty else { return }
        
        
        APIClient.shared.useAiPoll(command: command) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("successfully created AI poll view")
                    //isCreatingPoll = false
                    // After creation, ask user if they want to navigate to that poll?
                    //fetchPolls()
                case .failure(let error):
                    //isCreatingPoll = false
                    print(error.localizedDescription)
                    //statusMessage = error.localizedDescription
                }
            }
        }
        
    }
    
}

