//
//  TicTacToeApp.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 28/06/25.
//

import SwiftUI
import Firebase
@main
struct TicTacToeApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
           Home()
        }
    }
}
