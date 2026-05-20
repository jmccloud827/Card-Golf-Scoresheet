import Foundation
import SwiftData

@Model final class Game {
    var name: String
    private var persistedPlayers: [Player]
    var persistedHands: [Hand]
    var created = Date.now
    
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
    
    init(name: String, players: [String]) {
        self.name = name
        self.persistedPlayers = players.map { .init(name: $0) }
        self.persistedHands = []
        for index in 1 ... 18 {
            let hand = Hand(number: index, players: self.players)
            self.persistedHands.append(hand)
        }
    }
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
