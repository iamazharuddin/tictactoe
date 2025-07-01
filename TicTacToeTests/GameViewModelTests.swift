//
//  GameViewModelTests.swift
//  TicTacToe
//
//  Created by Azharuddin 1 on 01/07/25.
//

import XCTest
@testable import TicTacToe
internal import Combine

@MainActor
class GameViewModelTests: XCTestCase {
    var viewModel: GameViewModel!
    var mockService: MockGameService!

    override func setUp() {
        super.setUp()
        mockService = MockGameService()
        viewModel = GameViewModel(gameService: mockService)
    }

    func testCreateNewGame_SetsGameIdAndUserId() async {
        await viewModel.createNewGame(playerId: "user1")

        XCTAssertEqual(viewModel.userId, "user1")
        XCTAssertEqual(viewModel.gameId, "mockGame123")
    }

    func testJoinExistingGame_SetsGameIdAndUserId() async {
        await viewModel.joinExistingGame(playerId: "user2")
        XCTAssertEqual(viewModel.userId, "user2")
        XCTAssertEqual(viewModel.gameId, "mockGame123")
    }


    @MainActor
    func testMakeMove_UpdatesBoardAndTurn() async {
        let gameExpectation = XCTestExpectation(description: "Wait for currentGame to be set")
        let boardUpdateExpectation = XCTestExpectation(description: "Wait for board[0] to be 'X'")

        // 1. Wait for currentGame to be set
        let currentGameCancellable = viewModel.$currentGame
            .dropFirst()
            .sink { game in
                if game != nil {
                    gameExpectation.fulfill()
                }
            }

        // 2. Observe board update
        let boardCancellable = viewModel.$board
            .dropFirst()
            .sink { board in
                if board[0] == "X" {
                    boardUpdateExpectation.fulfill()
                }
            }

        // Trigger game creation
        await viewModel.createNewGame(playerId: "user1")

        // ✅ Wait until currentGame is non-nil
        await fulfillment(of: [gameExpectation], timeout: 1.0)

        // Now it’s safe to call makeMove
        await viewModel.makeMove(at: 0)

        // ✅ Wait for board to be updated
        await fulfillment(of: [boardUpdateExpectation], timeout: 1.0)

        XCTAssertEqual(viewModel.board[0], "X")
        XCTAssertEqual(viewModel.currentTurn, "O")

        currentGameCancellable.cancel()
        boardCancellable.cancel()
    }




    func testCheckWinner_DetectsWinInRow() {
        let game = Game(
            id: "mockGame",
            boardSize: 3, playerX: "user1",
            playerO: "user2",
            moves: [
                Move(row: 0, col: 0, player: "X"),
                Move(row: 0, col: 1, player: "X"),
            ],
            winner: nil,
            currentTurn: "O"
        )

        let move = Move(row: 0, col: 2, player: "X")
        let winner = viewModel.checkWinner(game: game, move: move)

        XCTAssertEqual(winner, "X")
    }

    func testResetGame_ClearsBoardAndWinner() async {
        await viewModel.createNewGame(playerId: "user1")
        await viewModel.makeMove(at: 0)
        await viewModel.resetGame()

        XCTAssertEqual(viewModel.board.filter { !$0.isEmpty }.count, 0)
        XCTAssertNil(viewModel.winner)
        XCTAssertEqual(viewModel.currentTurn, "X")
    }
}

