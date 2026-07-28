import Foundation
import SwiftData
import SwiftUI

@Model final class Player {
    var id = UUID()
    var name: String
    var picture: Data?
    var created = Date.now
    var avatarColorIndex = 0
    var avatarEmoji = "🙂"
    @Relationship(inverse: \Card.persistedPlayers) var cards: [Card] = []

    init(name: String) {
        self.name = name
        self.avatarColorIndex = AvatarColor.allCases.randomElement()?.rawValue ?? 0
        self.avatarEmoji = Player.emojiOptions.randomElement() ?? "🙂"
    }

    var avatarColor: Color {
        AvatarColor(rawValue: avatarColorIndex)?.color ?? .gray
    }

    enum AvatarColor: Int, CaseIterable {
        case red, orange, green, mint, teal, cyan, blue, indigo, purple, pink

        var color: Color {
            switch self {
            case .red: .red
            case .orange: .orange
            case .green: .green
            case .mint: .mint
            case .teal: .teal
            case .cyan: .cyan
            case .blue: .blue
            case .indigo: .indigo
            case .purple: .purple
            case .pink: .pink
            }
        }
    }

    static let emojiOptions = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
        "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🦆", "🦉",
        "🐺", "🐗", "🐴", "🦄", "🐝", "🐢", "🐍", "🦎", "🐙", "🦑",
        "🐠", "🐬", "🐳", "🦈", "🐊", "🦓", "🦒", "🐘", "🦔", "🐿️",
    ]

    var completedCards: [Card] {
        cards.filter { $0.finished != nil }
    }

    var averageScore: Double {
        let totalOfAllCards = completedCards.map { $0.getTotal(for: self) }.reduce(0, +)

        return Double(totalOfAllCards) / Double(completedCards.count)
    }

    var bestScore: Int {
        completedCards.map { $0.getTotal(for: self) }.sorted(by: <).first!
    }

    var worstScore: Int {
        completedCards.map { $0.getTotal(for: self) }.sorted(by: >).first!
    }

    var cardsPlayed: Int {
        completedCards.count
    }

    var wins: Int {
        completedCards.filter { $0.winner.id == id }.count
    }

    var winRate: Double {
        guard cardsPlayed > 0 else { return 0 }
        return Double(wins) / Double(cardsPlayed)
    }

    var bestHole: Int? {
        completedCards
            .flatMap { $0.getHands(for: self) }
            .compactMap(\.value)
            .min()
    }

    struct ScorePoint: Identifiable {
        var id: Date { date }
        let date: Date
        let score: Int
    }

    var scoreHistory: [ScorePoint] {
        completedCards
            .sorted { $0.created < $1.created }
            .map { ScorePoint(date: $0.created, score: $0.getTotal(for: self)) }
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
