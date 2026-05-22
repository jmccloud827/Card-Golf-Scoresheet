import Foundation
import SwiftData

@Model final class Game {
    var name: String
    var persistedPlayers: [Player]
    var persistedHands: [Hand]
    var created = Date.now
    var finished : Date?
    
    @Transient var players: [Player] {
        get {
            persistedPlayers.sorted { $0.name < $1.name }
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
    
    init(name: String, players: [Card_Golf_Scoresheet.Player]) {
        self.name = name
        self.persistedPlayers = players
        self.persistedHands = []
        for index in 1 ... 18 {
            let hand = Hand(number: index, players: self.players)
            self.persistedHands.append(hand)
        }
        
        for player in players {
            player.games.append(self)
        }
    }
    
    var winner: Player {
        players.sorted { getTotal(for: $0) > getTotal(for: $1) }.first!
    }
    
    func getHands(for player: Player) -> [Hand.Score] {
        hands.flatMap { $0.scores }.filter {$0.playerID == player.id }
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
    
    func markAsFinished() {
        finished = .now
    }
    
    @Model final class Hand {
        var number: Int
        private var persistedScores: [Score]
        
        var scores: [Score] {
            get {
                persistedScores.sorted { $0.playerName < $1.playerName }
            }
            
            set {
                persistedScores = newValue
            }
        }
        
        init(number: Int, players: [Player]) {
            self.number = number
            self.persistedScores = players.map { .init(player: $0) }
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
}

extension Game {
    static let example1 = Game(name: "Game 1", players: Player.examples).randomResult()
    static let example2 = Game(name: "Game 2", players: Player.examples).randomResult()
    static let example3 = Game(name: "Game 3", players: Player.examples).randomResult()
    static let example4 = Game(name: "Game 4", players: Player.examples).randomResult()
    static let example5 = Game(name: "Game 5", players: Player.examples).randomResult()
    static let example6 = Game(name: "Game 6", players: Player.examples).randomResult()
    static let example7 = Game(name: "Game 7", players: Player.examples).randomResult()
    static let example8 = Game(name: "Game 8", players: Player.examples).randomResult()
    static let example9 = Game(name: "Game 9", players: Player.examples).randomResult()
    
    static let examples: [Game] = [.example1, .example2, .example3, .example4, .example5, .example6, .example7, .example8, .example9]
    
    fileprivate func randomResult() -> Game {
        self.hands.forEach { hand in
            hand.scores.forEach { score in
                score.value = Int.random(in: 0...20)
            }
        }
        
        self.markAsFinished()
        
        return self
    }
}
