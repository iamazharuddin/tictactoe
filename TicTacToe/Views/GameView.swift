import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        Task { await viewModel.resetGame() }
                    } label: {
                        Label("Reset", systemImage: "arrow.clockwise.circle.fill")
                            .labelStyle(IconOnlyLabelStyle())
                            .foregroundColor(.blue)
                            .font(.title2)
                            .padding(8)
                    }
                }
                .padding(.horizontal)


                if let game = viewModel.currentGame {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You are: \(viewModel.userId)")
                            .font(.subheadline)

                        if viewModel.userId == game.playerX {
                            Text("Your Role: X")
                            Text("Opponent: \(game.playerO == "waiting" ? "Waiting..." : game.playerO)")
                        } else if viewModel.userId == game.playerO {
                            Text("Your Role: O")
                            Text("Opponent: \(game.playerX)")
                        } else {
                            Text("You are not a player in this game.")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .frame(height: 120)
                }

                if let winner = viewModel.winner {
                    Text("\(winner) won!")
                        .font(.title)
                        .foregroundColor(.green)
                }

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
                        .disabled(!viewModel.isMyTurn || viewModel.board[index] != "")
                    }
                }

                Text("Current Turn: \(viewModel.currentTurn)")
                    .font(.headline)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                viewModel.listenToGame()
            }
        }
    }
}


#Preview {
    GameView(viewModel: GameViewModel(gameService: GameService()))
}
