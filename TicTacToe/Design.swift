//
//  Design.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 29/06/25.
//

/*
HLD
  Login User
  Create Game using user id
  Setup Board
  Perform Move and update move in firebase
  Register Listner
  Declare Winner

LLD
   Login User
   let userID = FirebaseAuth.login()
   Create Game or Join Already Created Game
   Add Listner on game document
   Perform Move

 Game - Collectio or Model

 id:String
 boardSize: Int
 playerX:String
 playerO:String
 winner:String?
 currentTurn: String
 moves: [Moves]

 Moves
  row: Int
  col:Int
  player:String



Create the Game
  let ref = try await db.collection("game").document("gameId").setData(gameData)

Setup board
 self.board = Array(repeating: "", count: boardSize)
 for move in moves {
     let index = move.row * boradSize + move.col
     board[index] = move.player
 }

Join Game

Observe Game

Perform the move
     let move = Move(row: index/self.game.boardSize, col: index%self.game.boardSize, player: currentTurn)
     currentTurn = move.player == X ? O : X

     gameService.performMove(gameIf:String, move:Move) {
       let ref =   db.collection("games").document(gameId)
       ref.updateData(
            "moves": FieldValue.arrayUnion([try! FireStore.Encoder().encode(move))],
            "currentTurn" : currentTurn
       )
     }

Declare Winner
   winner logic
   let player = currentPlayer == "X" ? +1 : -1
   for move in moves {
       row[move.row] += player
       col[move.col] += player
       diagA += player
       diagB += player
   }

   if   abs(row.max()!) == self.boardSize || abs(col.max()!) == self.boardSize
    || diagA == self.boardSize || diagB == self.boardSize {
     return player
   }
 */


