//
//  GameDetailViewModel.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 28/06/25.
//

import Foundation
import Combine
import FirebaseFirestore

import FirebaseAuth

@MainActor
class GameViewModel: ObservableObject {
    @Published var board: [String] = Array(repeating: "", count: 9)
    @Published var gameId: String?
    @Published var currentTurn: String = "X"
    @Published var winner: String?
    @Published var currentGame: Game?
    private let gameService = GameService()
    private let boardSize = 3
    var userId: String = "" // set after login

    func createNewGame(playerId: String) async {
        userId = playerId
        gameId = try? await gameService.createGame(playerX: playerId, playerO: "waiting")
        listenToGame()
    }

    func joinExistingGame(playerId: String) async {
        userId = playerId
        do {
            gameId = try await gameService.joinAvailableGame(userId: playerId)
            listenToGame()
        } catch {
            print("❌ No game to join: \(error.localizedDescription)")
        }
    }

    func listenToGame() {
        guard let id = gameId else { return }
        gameService.listenToGame(gameId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let game):
                    self.currentGame = game
                    self.board = Array(repeating: "", count: game.boardSize * game.boardSize)
                    for move in game.moves {
                        self.board[move.row * game.boardSize + move.col] = move.player
                    }
                    self.currentTurn = game.currentTurn
                    self.winner = game.winner
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    

    func makeMove(at index: Int) async {
        guard winner == nil, board[index] == "", isMyTurn else { return }
        let row = index / boardSize
        let col = index % boardSize
        let move = Move(row: row, col: col, player: currentTurn)
        try? await gameService.makeMove(gameId: gameId!, move: move)
        if let winner = checkWinner(game: currentGame!, move: move) {
            print("winner = \(winner), moves = \(currentGame!.moves)")
            try? await gameService.declareWinner(gameId: gameId ?? "", winner: winner)
        }
    }

    func checkWinner(game: Game, move: Move) -> String? {
        let size = game.boardSize
        let player = move.player
        let moves = Set(game.moves + [move])

        // Track how many moves by this player per row/col
        var rowCounts = [Int](repeating: 0, count: size)
        var colCounts = [Int](repeating: 0, count: size)
        var diagCount = 0
        var antiDiagCount = 0

        for m in moves {
            guard m.player == player else { continue }

            rowCounts[m.row] += 1
            colCounts[m.col] += 1

            if m.row == m.col {
                diagCount += 1
            }
            if m.row + m.col == size - 1 {
                antiDiagCount += 1
            }
        }

        print(rowCounts, colCounts, diagCount, antiDiagCount)

        // Check if any row, col, or diagonal is full
        if rowCounts.contains(size) || colCounts.contains(size) || diagCount == size || antiDiagCount == size {
            return player
        }

        return nil
    }



    var isMyTurn: Bool {
        guard let game = currentGame else { return false }

        // Determine user's assigned letter
        let mySymbol: String
        if userId == game.playerX {
            mySymbol = "X"
        } else if userId == game.playerO {
            mySymbol = "O"
        } else {
            return false
        }

        return game.currentTurn == mySymbol
    }


    func resetGame() async {
        try? await gameService.reset(gameId: gameId!)
    }
}
