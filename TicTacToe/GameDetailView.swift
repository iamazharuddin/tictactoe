import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Game Info Section
            if let game = viewModel.currentGame {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🆔 Game ID: \(viewModel.gameId ?? "-")")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("👤 You are: \(viewModel.userId)")
                        .font(.subheadline)

                    if viewModel.userId == game.playerX {
                        Text("🎮 Your Role: X")
                        Text("🤝 Opponent: \(game.playerO == "waiting" ? "Waiting..." : game.playerO)")
                    } else if viewModel.userId == game.playerO {
                        Text("🎮 Your Role: O")
                        Text("🤝 Opponent: \(game.playerX)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }

            // MARK: - Winner UI
            if let winner = viewModel.winner {
                Text("\(winner) won! 🎉")
                    .font(.title)
                    .foregroundColor(.green)

            }

            Button("Reset Game") {
                Task { await viewModel.resetGame() }
            }

            // MARK: - Game Board
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<viewModel.board.count, id: \.self) { index in
                    Button {
                        Task { await viewModel.makeMove(at: index) }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cyan)
                                .frame(width: 100, height: 100)
                            Text(viewModel.board[index])
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                        }
                    }
//                    .disabled(!viewModel.isMyTurn || viewModel.board[index] != "")
                }
            }

            // MARK: - Current Turn Info
            Text("Current Turn: \(viewModel.currentTurn)")
                .font(.headline)
        }
        .padding()
        .onAppear {
            viewModel.listenToGame()
        }
    }
}
