import SwiftUI
import SwiftData

struct NewCardEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.created, order: .reverse) private var players: [Player]
    @Query(sort: \Card.created, order: .reverse) private var cards: [Card]
    
    @State private var name = ""
    @State private var selectedPlayers: [Player] = []

    var body: some View {
        NavigationView {
            List {
                TextField("Name", text: $name)
                
                Section {
                    Button {
                        let player = Player(name: "Player \(players.count + 1)")
                        modelContext.insert(player)
                        selectedPlayers.append(player)
                    } label: {
                        Label("Add New Player", systemImage: "plus")
                    }

                    ForEach(selectedPlayers, id: \.id) { player in
                        SelectablePlayerLabel(player: player, selectedPlayers: $selectedPlayers)
                            .id("selected-\(player.id)")
                    }
                    .onMove { source, destination in
                        selectedPlayers.move(fromOffsets: source, toOffset: destination)
                    }
                } header: {
                    Text("Players (\(selectedPlayers.count))")
                        .contentTransition(.numericText())
                }
                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                  0
                }

                Section("Recent Players") {
                    ForEach(players.filter { !selectedPlayers.contains($0) }, id: \.id) { player in
                        SelectablePlayerLabel(player: player, selectedPlayers: $selectedPlayers)
                            .id("recent-\(player.id)")
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                  0
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem {
                    EditButton()
                        .disabled(selectedPlayers.count < 2)
                }

                ToolbarItem {
                    Button("Create", role: .confirm) {
                        modelContext.insert(Card(name: name, players: selectedPlayers))

                        dismiss()
                    }
                    .disabled(selectedPlayers.count < 2)
                }
            }
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = "Card \(cards.count + 1)"
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
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NewCardEditor()
        .modelContainer(.previewContainer)
}
