//
//  AppViewModel.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 30/06/25.
//



import FirebaseAuth
import Foundation
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var userId: String?

    func signIn() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let user = result?.user {
                self?.userId = user.uid
                print("Logged in as: \(user.uid)")
            } else if let error = error {
                print("Auth error: \(error.localizedDescription)")
            }
        }
    }
}


