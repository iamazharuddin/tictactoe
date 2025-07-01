//
//  GameService.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 28/06/25.
//

import FirebaseFirestore
import Foundation


protocol GameServiceProtocol {
    func createGame(playerX: String, playerO: String) async throws -> String
    func joinAvailableGame(userId: String) async throws -> String
    func listenToGame(gameId: String, completion: @escaping (Result<Game, Error>) -> Void)
    func makeMove(gameId: String, move: Move) async throws
    func declareWinner(gameId: String, winner: String) async throws
    func reset(gameId: String) async throws
}


enum GameJoinError: Error, LocalizedError {
    case noAvailableGame
    var errorDescription: String? {
        switch self {
        case .noAvailableGame:
            return "No open games are available to join right now."
        }
    }
}


class GameService: GameServiceProtocol {
    private let db = Firestore.firestore()

    func createGame(playerX: String, playerO: String) async throws -> String {
        let gameData: [String: Any] = [
            "playerX": playerX,
            "playerO": playerO,
            "players": [playerX, playerO],
            "boardSize": 3,
            "moves": [],
            "currentTurn": "X",
            "winner": NSNull(),
            "status": "active",
            "createdAt": FieldValue.serverTimestamp()
        ]

        let ref = try await db.collection("game").addDocument(data: gameData)
        return ref.documentID
    }

    func joinAvailableGame(userId: String) async throws -> String {
        let snapshot = try await db.collection("game").getDocuments()

        for doc in snapshot.documents {
            let data = doc.data()
            let playerX = data["playerX"] as? String ?? ""
            let gameId = doc.documentID

            if playerX == userId {
                print("Rejoining your own game: \(gameId)")
                return gameId
            } else {
                try await db.collection("game").document(gameId).updateData([
                    "playerO": userId
                ])
                print("Joined game as playerO: \(gameId)")
                return gameId
            }
        }

        throw GameJoinError.noAvailableGame
    }


    func makeMove(gameId: String, move: Move) async throws {
        let ref = db.collection("game").document(gameId)
        try await ref.updateData([
            "moves": FieldValue.arrayUnion([try Firestore.Encoder().encode(move)]),
            "currentTurn": move.player == "X" ? "O" : "X"
        ])
    }


    func declareWinner(gameId: String, winner: String) async throws {
        let ref = db.collection("game").document(gameId)
        try await ref.updateData(["winner": winner])
    }


    func listenToGame(gameId: String, completion: @escaping (Result<Game, Error>) -> Void) {
        db.collection("game").document(gameId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let data = try? snapshot?.data(as: Game.self) {
                    completion(.success(data))
                }
            }
    }

    func reset(gameId: String) async throws {
        let ref = db.collection("game").document(gameId)
        try await ref.updateData([
            "moves": [],
            "winner": NSNull(),
            "currentTurn": "X"
        ])
    }
}
