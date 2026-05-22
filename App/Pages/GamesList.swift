import SwiftData
import SwiftUI

struct GamesList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Game.created, order: .reverse) private var games: [Game]
    @Query(sort: \Player.created) private var players: [Player]
    
    @State private var isShowingNewGameSheet = false

    var body: some View {
        NavigationSplitView {
            List {
                Section {} header: {
                    Text("Players")
                } footer: {}
                    .listSectionMargins(.vertical, 0)
                
                Section {} header: {} footer: {
                    Group {
                        if players.isEmpty {
                            ContentUnavailableView("No Players",
                                                   systemImage: "person.3",
                                                   description: Text("Players will appear here once added."))
                        } else {
                            ScrollView([.horizontal], showsIndicators: false) {
                                HStack {
                                    ForEach(players) { player in
                                        NavigationLink {
                                            PlayerDetails(player: player)
                                        } label: {
                                            PlayerLabel(player: player)
                                                .vertical()
                                        }
                                        .foregroundStyle(.foreground)
                                    }
                                }
                            }
                            .safeAreaPadding(.horizontal, 10)
                        }
                    }
                    .listRowInsets(.init())
                }
                .listSectionMargins(.all, 0)
                
                Section("Games") {
                    if games.isEmpty {
                        ContentUnavailableView("No Games",
                                               systemImage: "suit.spade",
                                               description: Text("New games will appear here once added."))
                    } else {
                        ForEach(games) { game in
                            NavigationLink {
                                Scoresheet(game: game)
                            } label: {
                                GameLabel(game: game)
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    modelContext.delete(game)
                                }
                                
                                if game.finished == nil {
                                    Button {
                                        game.markAsFinished()
                                    } label: {
                                        Label("Mark as finished", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
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
}

#Preview {
    GamesList()
        .modelContainer(.previewContainer)
}
