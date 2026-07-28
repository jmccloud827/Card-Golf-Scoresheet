import Charts
import SwiftData
import SwiftUI

struct PlayerDetails: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var player: Player

    var body: some View {
        List {
            PlayerLabelEditor(player: player)

            if player.scoreHistory.count >= 2 {
                Section("Trend") {
                    ScoreTrendChart(history: player.scoreHistory)
                        .padding(.vertical, 4)
                }
            }

            if !player.completedCards.isEmpty {
                Section("Stats") {
                    LabeledContent {
                        Text(player.cardsPlayed, format: .number)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    } label: {
                        Label("Cards Played", systemImage: "flag.checkered")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent {
                        HStack(spacing: 4) {
                            Text(player.wins, format: .number)

                            Text("(\(player.winRate.formatted(.percent.precision(.fractionLength(0)))))")
                                .foregroundStyle(.secondary)
                        }
                        .fontWeight(.medium)
                        .monospacedDigit()
                    } label: {
                        Label("Wins", systemImage: "trophy.fill")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent {
                        Text(player.averageScore, format: .number.precision(.fractionLength(2)))
                            .fontWeight(.medium)
                            .monospacedDigit()
                    } label: {
                        Label("Average Score", systemImage: "chart.bar.fill")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent {
                        Text(player.bestScore, format: .number)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(.green)
                    } label: {
                        Label("Best Card", systemImage: "arrow.down.circle.fill")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent {
                        Text(player.worstScore, format: .number)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    } label: {
                        Label("Worst Card", systemImage: "arrow.up.circle.fill")
                            .foregroundStyle(.secondary)
                    }

                    if let bestHole = player.bestHole {
                        LabeledContent {
                            Text(bestHole, format: .number)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                                .foregroundStyle(.green)
                        } label: {
                            Label("Best Hole", systemImage: "target")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Section {
                    ContentUnavailableView("No Stats Yet",
                                           systemImage: "chart.bar",
                                           description: Text("Finish a card with this player to see their stats here."))
                        .listRowInsets(.init())
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ScoreTrendChart: View {
    let history: [Player.ScorePoint]

    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDate: Date?

    private var tooltipBackground: Color {
        colorScheme == .dark ? Color(white: 0.22) : Color(white: 0.97)
    }

    private var tooltipBorder: Color {
        colorScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.1)
    }

    private var tooltipTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var selectedPoint: Player.ScorePoint? {
        guard let selectedDate else {
            return nil
        }
        return history.min {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        }
    }

    private var yAxisDomain: ClosedRange<Int> {
        let scores = history.map(\.score)
        let minScore = scores.min() ?? 0
        let maxScore = scores.max() ?? 0
        let padding = max(10, (maxScore - minScore) / 5)
        return (minScore - padding) ... (maxScore + padding)
    }

    var body: some View {
        Chart(history) { point in
            LineMark(x: .value("Date", point.date),
                     y: .value("Score", point.score))
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.accent)

            PointMark(x: .value("Date", point.date),
                      y: .value("Score", point.score))
                .symbolSize(point.id == history.last?.id ? 90 : 40)
                .foregroundStyle(.accent)

            if point.id == history.last?.id {
                PointMark(x: .value("Date", point.date),
                          y: .value("Score", point.score))
                    .symbolSize(0)
                    .annotation(position: .top) {
                        Text(point.score, format: .number)
                            .font(.caption.bold())
                            .monospacedDigit()
                    }
            }

            if let selectedPoint, selectedPoint.id == point.id {
                RuleMark(x: .value("Date", selectedPoint.date))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(.secondary)
                    .annotation(position: .top,
                                overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))) {
                        VStack(spacing: 2) {
                            Text(selectedPoint.score, format: .number)
                                .font(.caption.bold())
                                .monospacedDigit()
                                .foregroundStyle(tooltipTextColor)
                            Text(selectedPoint.date, format: .dateTime.month().day())
                                .font(.caption2)
                                .foregroundStyle(tooltipTextColor.opacity(0.6))
                        }
                        .padding(6)
                        .background(tooltipBackground, in: RoundedRectangle(cornerRadius: 6))
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(tooltipBorder, lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                    }
            }
        }
        .frame(height: 160)
        .chartYScale(domain: yAxisDomain)
        .chartXSelection(value: $selectedDate)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 3))
        }
    }
}

#Preview {
    let _ = Card.examples
    PlayerDetails(player: .example1)
}
