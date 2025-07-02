# 🎮 Multiplayer Tic Tac Toe (iOS)

A real-time multiplayer Tic Tac Toe game built using **Swift**, **SwiftUI**, and **Firebase**.

---

## ✨ Features

- ✅ Live game creation and joining
- 🔁 Real-time sync using Firebase Firestore listeners
- 🔐 Anonymous Firebase Authentication
- 🧠 Smart win logic, draw detection & game reset
- 🧱 MVVM architecture with SwiftUI

---

## 📦 Architecture

- `GameService`: Handles all Firebase read/write operations
- `GameViewModel`: Connects game logic and real-time updates to SwiftUI views
- `Game`, `Move`: Codable models synced with Firestore
- `GameBoardView`: SwiftUI-based UI grid for gameplay


# tictactoe<img width="720" alt="Screenshot 2025-06-30 at 1 11 52 PM" src="https://github.com/user-attachments/assets/f9c18527-ed7d-4dbf-b208-86ce7ff16462" />
