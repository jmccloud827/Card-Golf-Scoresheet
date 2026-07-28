import SwiftData
import SwiftUI

struct CardLabel: View {
    let card: Card

    private var duration: String? {
        guard let finished = card.finished else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: card.created, to: finished)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(card.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                CardStatusBadge(card: card)
            }

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .imageScale(.small)

                Text(card.created.formatted(date: .abbreviated, time: .shortened))

                if let duration {
                    Text("·")

                    Text(duration)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(1)

            VStack(alignment: .leading, spacing: 6) {
                Label("\(card.players.count) players", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if card.finished != nil {
                    CardScoreNumberLine(card: card)
                } else {
                    HStack(spacing: -10) {
                        ForEach(card.players) { player in
                            PlayerImage(player: player)
                                .frame(width: 28, height: 28)
                                .overlay(Circle().strokeBorder(.background, lineWidth: 2))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

struct CardStatusBadge: View {
    let card: Card

    var body: some View {
        Label(card.finished != nil ? "Finished" : "In Progress",
              systemImage: card.finished != nil ? "checkmark.circle.fill" : "repeat.circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(card.finished != nil ? .green : .accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((card.finished != nil ? Color.green : Color.accentColor).opacity(0.15), in: Capsule())
    }
}

private struct CardScoreNumberLine: View {
    let scoreEntries: [(player: Player, score: Int)]
    let minScore: Int
    let maxScore: Int

    init(card: Card) {
        let entries = card.players.map { (player: $0, score: card.getTotal(for: $0)) }
        scoreEntries = entries
        minScore = entries.map(\.score).min() ?? 0
        maxScore = entries.map(\.score).max() ?? 0
    }

    private func xPosition(for score: Int, in width: CGFloat) -> CGFloat {
        guard maxScore > minScore else { return width / 2 }
        let ratio = Double(score - minScore) / Double(maxScore - minScore)
        return 18 + CGFloat(ratio) * (width - 36)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: max(width - 36, 0), height: 3)
                    .position(x: width / 2, y: 30)

                Text("\(minScore)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .position(x: 18, y: 50)

                if maxScore > minScore {
                    Text("\(maxScore)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(x: width - 18, y: 50)
                }

                ForEach(scoreEntries, id: \.player.id) { entry in
                    let isWinner = entry.score == minScore

                    PlayerImage(player: entry.player)
                        .frame(width: isWinner ? 32 : 26, height: isWinner ? 32 : 26)
                        .overlay(Circle().strokeBorder(isWinner ? Color.yellow : Color(.systemBackground), lineWidth: isWinner ? 2 : 1.5))
                        .position(x: xPosition(for: entry.score, in: width), y: 30)
                }
            }
        }
        .frame(height: 60)
    }
}

#Preview {
    CardLabel(card: .example1)
}
