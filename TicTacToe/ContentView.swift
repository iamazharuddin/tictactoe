//
//  ContentView.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 28/06/25.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct ContentView: View {
    @StateObject var appVM = AppViewModel()
    @StateObject var gameVM = GameViewModel()

    var body: some View {
        VStack {
            if let userId = appVM.userId {
                if let gameId = gameVM.gameId {
                    GameView(viewModel: gameVM)
                } else {
                    VStack {
                        Button("Start New Game") {
                            Task {
                                await gameVM.createNewGame(playerId: userId)
                            }
                        }

                        Button("Join Game") {
                              Task { await gameVM.joinExistingGame(playerId: userId) }
                          }
                    }
                }
            } else {
                ProgressView("Signing in...")
            }
        }
        .onAppear {
            appVM.signIn()
        }
    }
}


import FirebaseAuth

@MainActor
class AppViewModel: ObservableObject {
    @Published var userId: String?

    func signIn() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let user = result?.user {
                self?.userId = user.uid
                print("✅ Logged in as: \(user.uid)")
            } else if let error = error {
                print("❌ Auth error: \(error.localizedDescription)")
            }
        }
    }
}




/*

 create n * n board
 n * n

  Funcional Requirement
  Create a board of size n * n
  Login user to perform action
  Record the move in Firebase DB
  Update the move in real time
  Perfom logic who won

 Non functional requirement
 */

