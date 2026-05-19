import SwiftUI
import SwiftData

struct NewGameEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = Date.now.formatted()
    @State private var players: [Player] = []

    var body: some View {
        NavigationView {
            List {
                TextField("Name", text: $name)
                
                Section {
                    ForEach($players, id: \.id) { $player in
                        TextField("Name", text: $player.name)
                    }
                    .onDelete(perform: deletePlayers)
                    
                    Button {
                        withAnimation {
                            players.append(.init(name: "Player \(players.count + 1)"))
                        }
                    } label: {
                        Label("Add Player", systemImage: "plus")
                    }
                } header: {
                    Text("Players (\(players.count))")
                        .contentTransition(.numericText())
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
                    .disabled(players.count < 2)
                }
            }
            .navigationTitle("Create a New Game")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func deletePlayers(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                players.remove(at: index)
            }
        }
    }
}

#Preview {
    NewGameEditor()
        .modelContainer(for: Game.self, inMemory: true)
}
