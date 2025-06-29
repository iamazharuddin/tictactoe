//
//  Move.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 28/06/25.
//

import Foundation
import FirebaseFirestore

struct Move: Codable, Identifiable, Hashable {
    var id: String { "\(row)-\(col)-\(player)" }
    let row: Int
    let col: Int
    let player: String
}

struct Game: Codable, Identifiable {
    @DocumentID var id: String?
    let boardSize: Int
    let playerX: String
    let playerO: String
    let moves: [Move]
    let winner: String?
    let currentTurn: String
}

