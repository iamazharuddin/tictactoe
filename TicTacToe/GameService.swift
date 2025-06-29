//
//  GameService.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 28/06/25.
//

import FirebaseFirestore
import Foundation

class GameService {
    private let db = Firestore.firestore()

    // Create a new game
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
        // Fetch all games where playerO is "waiting"
        let snapshot = try await db.collection("game")
            .getDocuments()

        for doc in snapshot.documents {
            let data = doc.data()
            let playerX = data["playerX"] as? String ?? ""
            let gameId = doc.documentID

            if playerX == userId {
                // ✅ Player is rejoining their own created game
                print("Rejoining game previously created by user: \(gameId)")
                return gameId
            } else {
                // ✅ New user joining as playerO
                try await db.collection("game").document(gameId)
                    .updateData(["playerO": userId])
                print("Joined game as playerO: \(gameId)")
                return gameId
            }
        }

        throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No available games to join"])
    }


 

    // Make a move by gameId
    func makeMove(gameId: String, move: Move) async throws {
        let ref = db.collection("game").document(gameId)
        try await ref.updateData([
            "moves": FieldValue.arrayUnion([try Firestore.Encoder().encode(move)]),
            "currentTurn": move.player == "X" ? "O" : "X"
        ])
    }

    // Declare winner
    func declareWinner(gameId: String, winner: String) async throws {
        let ref = db.collection("game").document(gameId)
        try await ref.updateData(["winner": winner])
    }

    // Listen to game updates in real-time
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

    // Reset game board
    func reset(gameId: String) async throws {
        let ref = db.collection("game").document(gameId)
        try await ref.updateData([
            "moves": [],
            "winner": NSNull()
        ])
    }
}
