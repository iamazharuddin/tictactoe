//
//  MockGameService.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 01/07/25.
//


import XCTest
@testable import TicTacToe

class MockGameService: GameServiceProtocol {
    var mockGame: Game = Game(
        id: "mockGame123",
        boardSize: 3,
        playerX: "user1",
        playerO: "user2",
        moves: [],
        winner: nil,
        currentTurn: "X"
    )

    private var listenerCallback: ((Result<Game, Error>) -> Void)?

    func createGame(playerX: String, playerO: String) async throws -> String {
        return mockGame.id ?? ""
    }

    func joinAvailableGame(userId: String) async throws -> String {
        return mockGame.id ?? ""
    }

    func listenToGame(gameId: String, completion: @escaping (Result<Game, Error>) -> Void) {
        listenerCallback = completion
        completion(.success(mockGame))
    }

    func makeMove(gameId: String, move: Move) async throws {
        print("💥 Before move: \(mockGame.moves.count) moves")
        mockGame.moves.append(move)
        mockGame.currentTurn = (move.player == "X") ? "O" : "X"
        print("✅ After move: \(mockGame.moves.count) moves")

        listenerCallback?(.success(mockGame))
    }

    func declareWinner(gameId: String, winner: String) async throws {
        mockGame.winner = winner
        listenerCallback?(.success(mockGame))
    }

    func reset(gameId: String) async throws {
        mockGame.moves = []
        mockGame.currentTurn = "X"
        mockGame.winner = nil
        listenerCallback?(.success(mockGame))
    }
}
