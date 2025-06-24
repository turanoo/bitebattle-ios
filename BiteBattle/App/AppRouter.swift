import SwiftUI

struct AppRouter: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                if isLoggedIn {
                    HomeView(path: $path)
                } else {
                    LandingView(path: $path)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .poll:
                    PollsView(path: $path)
                case .account:
                    AccountView(path: $path)
                case .headToHead:
                    HeadToHeadView(path: $path)
                }
            }
        }
    }
}
