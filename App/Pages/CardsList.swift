import SwiftData
import SwiftUI

struct CardsList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Card.created, order: .reverse) private var cards: [Card]
    @Query(sort: \Player.created) private var players: [Player]
    
    @State private var isShowingNewCardSheet = false
    @State private var cardToDelete: Card?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationSplitView {
            List {
                Section {} header: {
                    Text("Players")
                } footer: {}
                    .listSectionMargins(.vertical, 0)
                
                Section {} header: {} footer: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(players) { player in
                                NavigationLink {
                                    PlayerDetails(player: player)
                                } label: {
                                    PlayerLabel(player: player)
                                        .vertical()
                                }
                                .foregroundStyle(.foreground)
                            }

                            addPlayerButton
                        }
                        .padding(.vertical, 4)
                    }
                    .safeAreaPadding(.horizontal, 10)
                    .listRowInsets(.init())
                }
                .listSectionMargins(.all, 0)
                
                Section {
                    if cards.isEmpty {
                        ContentUnavailableView("No Cards",
                                               systemImage: "suit.spade",
                                               description: Text("New cards will appear here once added."))
                    } else {
                        ForEach(cards) { card in
                            NavigationLink {
                                Scoresheet(card: card)
                            } label: {
                                CardLabel(card: card)
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    cardToDelete = card
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                if card.finished == nil {
                                    Button {
                                        card.markAsFinished()
                                    } label: {
                                        Label("Mark as finished", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                        }
                    }
                }
            }
            .toolbar {
                Button {
                    isShowingNewCardSheet = true
                } label: {
                    Label("Add Card", systemImage: "plus")
                }
            }
            .fullScreenCover(isPresented: $isShowingNewCardSheet) {
                NewCardEditor()
            }
            .confirmationDialog("Delete “\(cardToDelete?.name ?? "")”?",
                                 isPresented: $showDeleteConfirmation,
                                 titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let cardToDelete {
                        modelContext.delete(cardToDelete)
                    }
                    cardToDelete = nil
                }

                Button("Cancel", role: .cancel) {
                    cardToDelete = nil
                }
            } message: {
                Text("This will permanently delete this card and its scores.")
            }
            .navigationTitle("Card Golf")
        } detail: {
            ContentUnavailableView("No Card Selected",
                                   systemImage: "suit.spade",
                                   description: Text("Choose a card from the list to view its scoresheet."))
        }
    }

    private var addPlayerButton: some View {
        Button {
            let player = Player(name: "Player \(players.count + 1)")
            modelContext.insert(player)
        } label: {
            VStack(spacing: 6) {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundStyle(.secondary)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }

                Text("Add Player")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CardsList()
        .modelContainer(.previewContainer)
}
