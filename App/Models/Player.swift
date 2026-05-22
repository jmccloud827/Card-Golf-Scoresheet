import Foundation
import SwiftData

@Model final class Player {
    var id = UUID()
    var name: String
    var picture: Data?
    var created = Date.now
    @Relationship(inverse: \Game.persistedPlayers) var games: [Game] = []
    
    init(name: String) {
        self.name = name
    }
    
    var completedGames: [Game] {
        games.filter { $0.finished != nil }
    }
    
    var averageScore: Double {
        let totalOfAllGames = completedGames.map { $0.getTotal(for: self) }.reduce(0, +)
        
        return Double(totalOfAllGames) / Double(completedGames.count)
    }
    
    var bestScore: Int {
        completedGames.map { $0.getTotal(for: self) }.sorted(by: <).first!
    }
    
    var worstScore: Int {
        completedGames.map { $0.getTotal(for: self) }.sorted(by: >).first!
    }
}

extension Player {
    static let example1 = Player(name: "Player 1")
    static let example2 = Player(name: "Player 2")
    static let example3 = Player(name: "Player 3")
    static let example4 = Player(name: "Player 4")
    static let example5 = Player(name: "Player 5")
    static let example6 = Player(name: "Player 6")
    static let example7 = Player(name: "Player 7")
    static let example8 = Player(name: "Player 8")
    static let example9 = Player(name: "Player 9")
    
    static let examples: [Player] = [.example1, .example2, .example3, .example4, .example5, .example6, .example7, .example8, .example9]
}
