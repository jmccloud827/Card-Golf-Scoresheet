import Foundation
import SwiftData

@Model final class Player {
    var id = UUID()
    var name: String
    var game: Game?
    
    @Transient var hands: [Hand.Score] {
        game!.hands
            .flatMap { $0.scores }
            .filter { $0.playerID == id }
    }
    
    init(name: String) {
        self.name = name
    }
    
    var total: Int {
        hands.reduce(0) { $0 + ($1.value ?? 0) }
    }
    
    var front9Total: Int {
        hands.prefix(9).reduce(0) { $0 + ($1.value ?? 0) }
    }
    
    var back9Total: Int {
        hands.suffix(9).reduce(0) { $0 + ($1.value ?? 0) }
    }
}
