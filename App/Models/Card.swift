import Foundation
import SwiftData

@Model final class Card {
    var name: String
    var persistedPlayers: [Player]
    var playerOrder: [PlayerOrder]
    var persistedHands: [Hand]
    var created = Date.now
    var finished: Date?
    
    @Transient var players: [Player] {
        get {
            playerOrder
                .sorted(by: { $0.order < $1.order })
                .map { order in
                    persistedPlayers.first { $0.id == order.playerID }!
                }
        }
        
        set {
            persistedPlayers = newValue
        }
    }
    
    @Transient var hands: [Hand] {
        get {
            persistedHands.sorted { $0.number < $1.number }
        }
        
        set {
            persistedHands = newValue
        }
    }
    
    init(name: String, players: [Player]) {
        self.name = name
        self.persistedPlayers = players
        self.playerOrder = players.enumerated().map { .init(order: $0, playerID: $1.id) }
        self.persistedHands = []
        for index in 1 ... 18 {
            let hand = Hand(number: index, players: self.players, belongsTo: self)
            self.persistedHands.append(hand)
        }
        
        for player in players {
            player.cards.append(self)
        }
    }
    
    var winner: Player {
        players
            .map { ($0, getTotal(for: $0)) }
            .min { $0.1 < $1.1 }!
            .0
    }

    func getHands(for player: Player) -> [Hand.Score] {
        hands.compactMap { $0.score(for: player) }
    }
    
    func getTotal(for player: Player) -> Int {
        getHands(for: player).reduce(0) { $0 + ($1.value ?? 0) }
    }
    
    func getFront9(for player: Player) -> Int {
        getHands(for: player).prefix(9).reduce(0) { $0 + ($1.value ?? 0) }
    }
    
    func getBack9(for player: Player) -> Int {
        getHands(for: player).suffix(9).reduce(0) { $0 + ($1.value ?? 0) }
    }

    func getTotal(through holeNumber: Int, for player: Player) -> Int {
        getHands(for: player).prefix(holeNumber).reduce(0) { $0 + ($1.value ?? 0) }
    }
    
    func markAsFinished() {
        finished = .now
    }
    
    @Model final class Hand {
        var number: Int
        private var persistedScores: [Score]
        
        // Inverse
        var belongsTo: Card
        
        var scores: [Score] {
            get {
                belongsTo.playerOrder
                    .sorted(by: { $0.order < $1.order })
                    .map { order in
                        persistedScores.first { $0.playerID == order.playerID }!
                    }
            }
            
            set {
                persistedScores = newValue
            }
        }

        func score(for player: Player) -> Score? {
            persistedScores.first { $0.playerID == player.id }
        }

        init(number: Int, players: [Player], belongsTo: Card) {
            self.number = number
            self.persistedScores = players.map { .init(player: $0) }
            self.belongsTo = belongsTo
        }
        
        @Model final class Score {
            var playerID: UUID
            var playerName: String
            var value: Int?
            
            init(player: Player) {
                self.playerID = player.id
                self.playerName = player.name
            }
        }
    }
    
    @Model final class PlayerOrder {
        var order: Int
        var playerID: UUID
        
        init(order: Int, playerID: UUID) {
            self.order = order
            self.playerID = playerID
        }
    }
}

extension Card {
    static let example1 = Card(name: "Card 1", players: Player.examples).randomResult(daysAgo: 8)
    static let example2 = Card(name: "Card 2", players: Player.examples).randomResult(daysAgo: 7)
    static let example3 = Card(name: "Card 3", players: Player.examples).randomResult(daysAgo: 6)
    static let example4 = Card(name: "Card 4", players: Player.examples).randomResult(daysAgo: 5)
    static let example5 = Card(name: "Card 5", players: Player.examples).randomResult(daysAgo: 4)
    static let example6 = Card(name: "Card 6", players: Player.examples).randomResult(daysAgo: 3)
    static let example7 = Card(name: "Card 7", players: Player.examples).randomResult(daysAgo: 2)
    static let example8 = Card(name: "Card 8", players: Player.examples).randomResult(daysAgo: 1)
    static let example9 = Card(name: "Card 9", players: Player.examples).randomResult(daysAgo: 0)

    static let examples: [Card] = [.example1, .example2, .example3, .example4, .example5, .example6, .example7, .example8, .example9]

    fileprivate func randomResult(daysAgo: Int) -> Card {
        for hand in self.hands {
            for score in hand.scores {
                score.value = Int.random(in: 0 ... 20)
            }
        }

        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        created = date
        finished = date.addingTimeInterval(90 * 60)

        return self
    }
}
