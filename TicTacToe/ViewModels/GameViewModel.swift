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
    private let gameService: GameServiceProtocol
    private let boardSize = 3
    var userId: String = ""

    init(gameService:GameServiceProtocol) {
        self.gameService = gameService
    }

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
        gameService.listenToGame(gameId: id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let game):
                    self.currentGame = game
                    print("Moves: ", game.moves)
                    print("Current Turn: \(game.currentTurn)")
                    self.board = Array(repeating: "", count: game.boardSize * game.boardSize)
                    for move in game.moves {
                        self.board[move.row * game.boardSize + move.col] = move.player
                    }
                    print("Board: ", self.board)
                    self.currentTurn = game.currentTurn
                    self.winner = game.winner
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    

    func makeMove(at index: Int) async {
        print("🟡 makeMove called at index: \(index)")

        guard board[index] == "", isMyTurn else {
            print("⛔️ Move rejected — board[\(index)] = '\(board[index])', isMyTurn = \(isMyTurn)")
            return
        }

        let row = index / boardSize
        let col = index % boardSize
        let move = Move(row: row, col: col, player: currentTurn)
        print("✅ Making move for player: \(currentTurn), row: \(row), col: \(col)")

        try? await gameService.makeMove(gameId: gameId!, move: move)

        if let winner = checkWinner(game: currentGame!, move: move) {
            print("🎉 Winner = \(winner), moves = \(currentGame!.moves)")
            try? await gameService.declareWinner(gameId: gameId ?? "", winner: winner)
        }
    }

    func checkWinner(game: Game, move: Move) -> String? {
        let size = game.boardSize
        let player = move.player
        let moves = Set(game.moves + [move])

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

        if rowCounts.contains(size) || colCounts.contains(size) || diagCount == size || antiDiagCount == size {
            return player
        }

        return nil
    }



    var isMyTurn: Bool {
        guard let game = currentGame else {
            print("❌ isMyTurn: currentGame is nil")
            return false
        }

        let mySymbol: String
        if userId == game.playerX {
            mySymbol = "X"
        } else if userId == game.playerO {
            mySymbol = "O"
        } else {
            print("❌ isMyTurn: userId \(userId) not in game")
            return false
        }

        let result = game.currentTurn == mySymbol
        print("🧩 isMyTurn: userId=\(userId), mySymbol=\(mySymbol), game.currentTurn=\(game.currentTurn), result=\(result)")
        return result
    }



    func resetGame() async {
        try? await gameService.reset(gameId: gameId!)
    }
}
