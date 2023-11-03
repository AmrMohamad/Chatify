# Chatify a Chat App with Firebase

## Project Overview
This is a simple iOS chat application built using Firebase Firestore as the backend. It allows users to send messages to other users in real-time.

## Table of Contents
- [Features](#features)
- [Demo](#demo)
- [Usage](#usage)
- [Testing](#testing)
- [License](#license)

## Features

- [x] User create an account with email.
- [ ] User authentication with Google Sign-In.
- [x] Real-time chat with another User.
- [x] Show timestamp of the message.
- [ ] Send Image and Video.
- [ ] Send Location.
- [ ] Group chat functionality.
- [ ] Push notifications.
- [ ] Offline support for messaging.

## Demo

## Getting Started

```bash
# Clone the repository
git clone https://github.com/AmrMohamad/Chatify.git

# Install CocoaPods (if not already installed)
gem install cocoapods

# Navigate to the project directory
cd Chatify

# Install project dependencies using CocoaPods
pod install

# Open the Xcode workspace
open Chatify.xcworkspace
```

## Usage

1. Launch the app on your iOS device or simulator.
1. Sign in with your Google account(coming soon) or Create an account.
1. Start sending and receiving messages in real-time.

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Copyright © 2023, [Amr Mohamad](https://github.com/AmrMohamad).
Released under the [MIT License](./LICENSE.txt).


<!--
This is a simple iOS chat application built using Firebase as the backend. It allows users to sign in with their Google accounts and send messages to other users in real-time.

## Features

- User authentication with Google Sign-In
- Real-time messaging using Firebase Firestore
- Clean and intuitive user interface
- Message timestamp and sender information
- Offline support for messaging

## Requirements

- iOS 12.0+
- Xcode 12.0+
- Cocoapods (for Firebase dependencies)

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/yourusername/chat-app.git
cd chat-app
```

2. Install the required dependencies using Cocoapods:

```bash
pod install
```

3. Open the `ChatApp.xcworkspace` file in Xcode.

4. Set up Firebase in your project:
   - Create a new Firebase project on the [Firebase Console](https://console.firebase.google.com/).
   - Follow the instructions to add your iOS app to the project.
   - Download the `GoogleService-Info.plist` file and add it to your Xcode project.

5. Enable Google Sign-In in the Firebase Console:
   - Go to the Authentication section and enable Google as a sign-in method.

6. Run the app in the simulator or on a physical device.

## Firebase Configuration

This app uses Firebase for real-time messaging. The necessary Firebase configurations can be found in the `AppDelegate.swift` file. Make sure to replace the placeholders with your own Firebase credentials.

```swift
FirebaseApp.configure()
let db = Firestore.firestore()
```

## Directory Structure

```
- ChatApp
  - Controllers
    - ChatViewController.swift
    - ...
  - Models
    - Message.swift
    - ...
  - Views
    - MessageCell.swift
    - ...
  - Supporting Files
    - AppDelegate.swift
    - ...
```

## Usage

1. Launch the app on your iOS device or simulator.
2. Sign in with your Google account.
3. Start sending and receiving messages in real-time.

## Contributing

If you'd like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with a descriptive commit message.
4. Push your changes to your fork.
5. Submit a pull request to the `main` branch of the original repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Firebase](https://firebase.google.com/) for providing an easy-to-use backend service.
- [GoogleSignIn](https://developers.google.com/identity/sign-in/ios) for simplifying user authentication.

## Contact

For any inquiries or feedback, please contact [Your Name](mailto:youremail@example.com).

---

Feel free to customize this README according to your specific project details. Make sure to provide clear instructions for setting up and running the app, and include any additional information that may be relevant to developers or users.

-->