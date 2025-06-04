# BiteBattle iOS

BiteBattle iOS is the SwiftUI-based mobile client for the BiteBattle platform, enabling collaborative restaurant decision-making, group polls, and head-to-head food battles. It connects to the BiteBattle backend via RESTful APIs.

---

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Screenshots](#screenshots)
- [Project Structure](#project-structure)
- [Local Development](#local-development)
- [API & Backend](#api--backend)
- [Contributing](#contributing)
- [License](#license)

---

## Description

BiteBattle iOS provides a user-friendly interface for:
- Creating and joining polls to vote on restaurants
- Head-to-head food matchups
- Managing your account and authentication
- Searching for restaurants (powered by Google Places)

The app is built with SwiftUI and communicates with the [BiteBattle backend](https://github.com/turanoo/bitebattle) via RESTful APIs.

---

## Features

- **Authentication:** Register and log in with secure token-based authentication
- **Polls:** Create, join, and vote in group restaurant polls
- **Head-to-Head:** Compete in food matchups (coming soon)
- **Account Management:** Update your profile and manage your session
- **Modern UI:** Clean, minimal, and responsive SwiftUI design

---

## Project Structure

```
bitebattle-ios/
├── BiteBattle/
│   ├── App/                # App entry point and routing
│   ├── Assets.xcassets/    # App icons, colors, and assets
│   ├── Core/
│   │   ├── Models/         # Data models
│   │   └── Network/        # API client and endpoints
│   ├── Resources/          # Shared UI components (buttons, backgrounds, etc.)
│   └── Views/              # SwiftUI views (Home, Landing, Polls, Account, etc.)
├── BiteBattle.xcodeproj/   # Xcode project files
└── README.md               # This file
```

---

## Local Development

### Prerequisites
- Xcode 15+
- Swift 5.9+
- iOS 17+ simulator or device

### Setup
1. **Clone this repository:**
   ```sh
   git clone https://github.com/turanoo/bitebattle-ios.git
   cd bitebattle-ios
   ```
2. **Install dependencies:**
   - All dependencies are managed via Swift Package Manager (SPM). Open the project in Xcode and resolve packages if prompted.

3. **Backend server:**
   - The app requires the [BiteBattle backend server](https://github.com/turanoo/bitebattle) running locally (default: `http://localhost:8080`).
   - Follow the [server setup instructions](https://github.com/turanoo/bitebattle#installation-and-local-development) to start the backend.

4. **Run the app:**
   - Open `BiteBattle.xcodeproj` in Xcode.
   - Select a simulator or device and press **Run** (⌘R).

---

## API & Backend

- The iOS app communicates with the REST API provided by the [BiteBattle backend](https://github.com/turanoo/bitebattle).
- Update the API base URL in `Core/Network/Endpoints.swift` if your backend is running on a different host or port.

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.