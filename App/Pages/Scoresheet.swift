import SwiftUI

struct Scoresheet: View {
    @Bindable var game: Game
    
    @FocusState private var scorePosition: Int?

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                Divider()
                    
                playersHeader
                    
                scores
                    
                Divider()
                    
                ResultsRow(label: "Final", scores: game.players.map(\.total), backgroundColor: .red, scorePosition: scorePosition)
                    
                Divider()
            }
            .padding()
        }
        .defaultScrollAnchor(.topLeading)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {} label: {
                    Label("Previous", systemImage: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .keyboard) {
                Button {
                    scorePosition = scorePosition?.advanced(by: 1)
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
            }
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
        .environment(game)
    }
    
    private var playersHeader: some View {
        GridRow {
            HStack(spacing: 0) {
                Divider()
                    
                Spacer(minLength: 0)
                    
                Divider()
            }
                
            ForEach(game.players.enumerated(), id: \.element.id) { index, player in
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    Text(player.name)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        
                    Divider()
                }
                .background {
                    if let scorePosition {
                        let mod = scorePosition % game.players.count
                        if mod == index {
                            Color.gray.opacity(0.25)
                        }
                    }
                }
            }
        }
    }
    
    private var scores: some View {
        ForEach($game.hands, id: \.wrappedValue.number) { $hand in
            Divider()
                
            HandRow(hand: $hand, scorePosition: $scorePosition)
            
            if $hand.wrappedValue.number.isMultiple(of: 9) {
                Divider()
                
                ResultsRow(label: $hand.wrappedValue.number.isMultiple(of: 18) ? "Back" : "Front", scores: $hand.wrappedValue.number.isMultiple(of: 18) ? game.players.map(\.back9Total) : game.players.map(\.front9Total), backgroundColor: .green, scorePosition: scorePosition)
            }
        }
    }
}

private struct HandRow: View {
    @Environment(Game.self) private var game
    
    @Binding var hand: Hand
    var scorePosition: FocusState<Int?>.Binding
    
    var body: some View {
        GridRow {
            HStack(spacing: 0) {
                Divider()
                    
                Text("\(hand.number)")
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                    
                Spacer(minLength: 0)
                    
                Divider()
            }
            .background {
                if let scorePosition = scorePosition.wrappedValue {
                    let mod = scorePosition % game.players.count
                    if scorePosition - mod == hand.number * game.players.count {
                        Color.gray.opacity(0.25)
                    }
                }
            }
                
            ForEach($hand.scores.enumerated(), id: \.element.id) { index, $score in
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    TextField("0", value: $score.value, formatter: NumberFormatter())
                        .focused(scorePosition, equals: $hand.wrappedValue.number * game.players.count + index)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        
                    Divider()
                }
                .background {
                    if let scorePosition = scorePosition.wrappedValue {
                        let mod = scorePosition % game.players.count
                        if mod == index || scorePosition - mod == hand.number * game.players.count {
                            Color.gray.opacity(0.25)
                        }
                    }
                }
            }
        }
    }
}

private struct ResultsRow: View {
    @Environment(Game.self) private var game
    
    let label: String
    let scores: [Int]
    let backgroundColor: Color
    let scorePosition: Int?
    
    var body: some View {
        GridRow {
            HStack(spacing: 0) {
                Divider()
                    
                Text(label)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                
                Spacer(minLength: 0)
                    
                Divider()
            }
                
            ForEach(scores.enumerated(), id: \.offset) { index, score in
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    Text("\(score)")
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        
                    Divider()
                }
                .background {
                    if let scorePosition {
                        let mod = scorePosition % game.players.count
                        if mod == index {
                            Color.gray.opacity(0.25)
                        }
                    }
                    
                    backgroundColor.opacity(0.5)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        Scoresheet(game: .example)
    }
}

extension Game {
    static let example = Game(name: "New Game",
                              players: [
                                  .init(name: "Player 1"),
                                  .init(name: "Player 2"),
                                  .init(name: "Player 3"),
                                  .init(name: "Player 4"),
                                  .init(name: "Player 5"),
                                  .init(name: "Player 6"),
                                  .init(name: "Player 7"),
                                  .init(name: "Player 8"),
                                  .init(name: "Player 9")
                              ])
}
