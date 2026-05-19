import SwiftUI
import SwiftData

struct GamesList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Game.created, order: .reverse) private var games: [Game]
    
    @State private var isShowingNewGameSheet = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(games) { game in
                    NavigationLink {
                        Scoresheet(game: game)
                    } label: {
                        Text(game.name)
                    }
                }
                .onDelete(perform: deleteGames)
            }
            .overlay {
                if games.isEmpty {
                    ContentUnavailableView(
                        "No Games",
                        systemImage: "suit.spade",
                        description: Text("New games will appear here once added.")
                    )
                }
            }
            .toolbar {
                Button {
                    isShowingNewGameSheet = true
                } label: {
                    Label("Add Game", systemImage: "plus")
                }
            }
            .fullScreenCover(isPresented: $isShowingNewGameSheet) {
                NewGameEditor()
            }
            .navigationTitle("Games")
        } detail: {
            Text("Select a game")
        }
    }

    private func deleteGames(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(games[index])
            }
        }
    }
}

#Preview {
    GamesList()
        .modelContainer(for: Game.self, inMemory: true)
}
