import SwiftUI
import SwiftData

struct NewGameEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.created, order: .reverse) private var players: [Player]
    @Query(sort: \Game.created, order: .reverse) private var games: [Game]
    
    @State private var name = ""
    @State private var selectedPlayers: [Player] = []

    var body: some View {
        NavigationView {
            List {
                TextField("Name", text: $name)
                
                Section {
                    ForEach(selectedPlayers.enumerated(), id: \.offset) { index, player in
                        SelectablePlayerLabel(player: player, selectedPlayers: $selectedPlayers)
                    }
                    
                    Button {
                        withAnimation {
                            let player = Player(name: "Player \(players.count + 1)")
                            modelContext.insert(player)
                            selectedPlayers.append(player)
                        }
                    } label: {
                        Label("Add New Player", systemImage: "plus")
                    }
                } header: {
                    Text("Players (\(selectedPlayers.count))")
                        .contentTransition(.numericText())
                }
                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                  0
                }
                
                Section("Recent Players") {
                    ForEach(players.filter { !selectedPlayers.contains($0) }.enumerated(), id: \.offset) { index, player in
                        SelectablePlayerLabel(player: player, selectedPlayers: $selectedPlayers)
                    }
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

struct SelectablePlayerLabel: View {
    let player: Player
    @Binding var selectedPlayers: [Player]
    
    var body: some View {
        HStack {
            PlayerLabelEditor(player: player)
            
            Button {
                withAnimation {
                    if selectedPlayers.contains(player) {
                        selectedPlayers.removeAll { $0.id == player.id }
                    } else {
                        selectedPlayers.append(player)
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
}

#Preview {
    NewGameEditor()
        .modelContainer(.previewContainer)
}
