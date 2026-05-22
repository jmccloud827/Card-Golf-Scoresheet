import SwiftUI
import SwiftData

struct NewGameEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.created, order: .reverse) private var players: [Player]
    @Query(sort: \Game.created, order: .reverse) private var games: [Game]
    
    @State private var name = ""
    @State private var selectedPlayers: Set<Player> = []

    var body: some View {
        NavigationView {
            List {
                TextField("Name", text: $name)
                
                Section {
                    ForEach(players.enumerated(), id: \.offset) { index, player in
                        HStack {
                            PlayerLabelEditor(player: player)
                            
                            Button {
                                withAnimation {
                                    if selectedPlayers.contains(player) {
                                        selectedPlayers.remove(player)
                                    } else {
                                        selectedPlayers.insert(player)
                                    }
                                }
                            } label: {
                                Image(systemName: selectedPlayers.contains(player) ? "minus.circle.fill" :  "plus.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(selectedPlayers.contains(player) ? .red : .green)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                    }
                    
                    Button {
                        withAnimation {
                            let player = Player(name: "Player \(players.count + 1)")
                            modelContext.insert(player)
                            selectedPlayers.insert(player)
                        }
                    } label: {
                        Label("Add Player", systemImage: "plus")
                    }
                } header: {
                    Text("Players (\(selectedPlayers.count))")
                        .contentTransition(.numericText())
                }
                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                  0
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem {
                    Button(role: .confirm) {
                        modelContext.insert(Game(name: name, players: players))
                        
                        dismiss()
                    }
                    .disabled(selectedPlayers.count < 2)
                }
            }
            .navigationTitle("Create a New Game")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = "Game \(games.count + 1)"
            }
        }
    }
}

#Preview {
    NewGameEditor()
        .modelContainer(.previewContainer)
}
