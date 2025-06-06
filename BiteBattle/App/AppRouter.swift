import SwiftUI

struct AppRouter: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                HomeView()
            } else {
                LandingView()
            }
        }
    }
}
