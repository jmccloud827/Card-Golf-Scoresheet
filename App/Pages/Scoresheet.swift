import SwiftUI

private struct TopBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension View {
    /// Rounded, elevated card chrome shared by the grid and by-hole score surfaces.
    func scoreCardStyle(borderOpacity: Double = 0.2, shadowOpacity: Double = 0.08, shadowRadius: CGFloat = 10, shadowY: CGFloat = 4) -> some View {
        background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(borderOpacity), lineWidth: 1)
            }
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, y: shadowY)
    }
}

struct Scoresheet: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var card: Card

    @State private var showConfirmFinishDialog = false
    @State private var viewMode: ViewMode = .byHole
    @State private var holeIndex = 0
    @State private var topBarHeight: CGFloat = 0
    @FocusState private var scorePosition: Int?

    private enum ViewMode: String, CaseIterable {
        case byHole = "By Hole"
        case grid = "Grid"
    }

    private var hand: Card.Hand {
        card.hands[holeIndex]
    }

    private var focusedScore: Card.Hand.Score? {
        guard let scorePosition else { return nil }
        let hand = card.hands[(scorePosition / card.players.count) - 1]
        return hand.scores[scorePosition % card.players.count]
    }

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch viewMode {
                case .grid:
                    gridScoreView
                case .byHole:
                    RoundByRoundView(card: card, holeIndex: $holeIndex, topInset: topBarHeight)
                }
            }
            .animation(nil, value: viewMode)

            topBar
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onPreferenceChange(TopBarHeightPreferenceKey.self) { topBarHeight = $0 }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark")
                }
            }

            ToolbarItem(placement: .principal) {
                Picker("View", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }

            if viewMode == .grid {
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        scorePosition = scorePosition?.advanced(by: -1)
                    } label: {
                        Label("Previous", systemImage: "chevron.left")
                    }

                    Button {
                        scorePosition = scorePosition?.advanced(by: 1)
                    } label: {
                        Label("Next", systemImage: "chevron.right")
                    }

                    Spacer()
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        if let value = focusedScore?.value {
                            focusedScore?.value = value * -1
                        }
                    } label: {
                        if (focusedScore?.value ?? 0) < 0 {
                            Label("Positive", systemImage: "plus")
                        } else {
                            Label("Negative", systemImage: "minus")
                        }
                    }
                    .disabled(focusedScore?.value == nil)

                    Spacer()

                    Button {
                        scorePosition = nil
                    } label: {
                        Label("Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down")
                    }
                }
            }

            ToolbarItem {
                if card.finished == nil {
                    Button {
                        showConfirmFinishDialog = true
                    } label: {
                        Label("Mark as finished", systemImage: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                    .confirmationDialog("Are you sure you want to finish this card?", isPresented: $showConfirmFinishDialog, titleVisibility: .visible) {
                        Button("Yes, I'm done", role: .destructive) {
                            card.markAsFinished()
                        }
                    }
                }
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .environment(card)
    }

    private var topBar: some View {
        Group {
            if viewMode == .byHole {
                holeHeader
                    .padding(.top, 8)
            }
        }
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: TopBarHeightPreferenceKey.self, value: proxy.size.height)
            }
        }
    }

    private var holeHeader: some View {
        GlassEffectContainer {
            HStack {
                Button {
                    goToPreviousHole()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.glass)
                .disabled(holeIndex == 0)

                Spacer()

                VStack(spacing: 2) {
                    Text("Hole \(hand.number)")
                        .font(.title2.bold())
                        .contentTransition(.numericText(value: Double(hand.number)))

                    Text("of \(card.hands.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    goToNextHole()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.glass)
                .disabled(holeIndex == card.hands.count - 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width < 0 {
                        goToNextHole()
                    } else {
                        goToPreviousHole()
                    }
                }
        )
    }

    private func goToPreviousHole() {
        withAnimation {
            holeIndex = max(0, holeIndex - 1)
        }
    }

    private func goToNextHole() {
        withAnimation {
            holeIndex = min(card.hands.count - 1, holeIndex + 1)
        }
    }

    private var gridScoreView: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal]) {
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    playersHeader

                    scores

                    GridRule(emphasized: true)

                    ResultsRow(label: "Final",
                               scores: card.players.map { card.getTotal(for: $0) },
                               tint: .accentColor,
                               emphasized: true,
                               scorePosition: scorePosition)
                }
                // Every cell's HStack ends in a Spacer(minLength: 0), which makes Grid itself
                // report as flexible. Without fixedSize it would stretch to fill minWidth below
                // instead of staying at its natural size and letting frame(minWidth:) center it.
                .fixedSize(horizontal: true, vertical: false)
                .scoreCardStyle()
                .frame(minWidth: proxy.size.width)
                .padding()
            }
            .defaultScrollAnchor(.topLeading)
            .safeAreaPadding(.top, topBarHeight)
        }
    }

    private var playersHeader: some View {
        GridRow {
            HStack(spacing: 0) {
                GridColumnRule()

                Spacer(minLength: 0)

                GridColumnRule()
            }
            .background(Color.secondary.opacity(0.05))

            ForEach(card.players.enumerated(), id: \.element.id) { index, player in
                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    PlayerLabel(player: player, size: 50)
                        .vertical()
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)

                    GridColumnRule()
                }
                .background {
                    Color.secondary.opacity(0.05)

                    if let scorePosition {
                        let mod = scorePosition % card.players.count
                        if mod == index {
                            Color.secondary.opacity(0.25)
                        }
                    }
                }
            }
        }
    }

    private var scores: some View {
        ForEach($card.hands, id: \.wrappedValue.number) { $hand in
            GridRule(emphasized: $hand.wrappedValue.number == 1)

            HandRow(hand: $hand, scorePosition: $scorePosition)

            if $hand.wrappedValue.number.isMultiple(of: 9) {
                GridRule(emphasized: true)

                ResultsRow(label: $hand.wrappedValue.number.isMultiple(of: 18) ? "Back" : "Front",
                           scores: card.players.map { $hand.wrappedValue.number.isMultiple(of: 18) ? card.getBack9(for: $0) : card.getFront9(for: $0) },
                           tint: .secondary,
                           emphasized: false,
                           scorePosition: scorePosition)
            }
        }
    }
}

private struct GridRule: View {
    var emphasized: Bool = false

    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(emphasized ? 0.35 : 0.15))
            .frame(height: emphasized ? 1.5 : 1)
    }
}

private struct GridColumnRule: View {
    var emphasized: Bool = false

    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(emphasized ? 0.35 : 0.15))
            .frame(width: emphasized ? 1.5 : 1)
    }
}

private struct HandRow: View {
    @Environment(Card.self) private var card
    
    @Binding var hand: Card.Hand
    var scorePosition: FocusState<Int?>.Binding
    
    private var isAlternateRow: Bool {
        !hand.number.isMultiple(of: 2)
    }

    var body: some View {
        GridRow {
            HStack(spacing: 0) {
                GridColumnRule()

                Text("\(hand.number)")
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)

                Spacer(minLength: 0)

                GridColumnRule()
            }
            .background {
                if isAlternateRow {
                    Color.secondary.opacity(0.035)
                }

                if let scorePosition = scorePosition.wrappedValue {
                    let mod = scorePosition % card.players.count
                    if scorePosition - mod == hand.number * card.players.count {
                        Color.secondary.opacity(0.25)
                    }
                }
            }

            ForEach($hand.scores.enumerated(), id: \.element.id) { index, $score in
                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    TextField("0", value: $score.value, formatter: NumberFormatter())
                        .focused(scorePosition, equals: $hand.wrappedValue.number * card.players.count + index)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)

                    GridColumnRule()
                }
                .background {
                    if isAlternateRow {
                        Color.secondary.opacity(0.035)
                    }

                    if let scorePosition = scorePosition.wrappedValue {
                        let mod = scorePosition % card.players.count
                        if mod == index || scorePosition - mod == hand.number * card.players.count {
                            Color.secondary.opacity(0.25)
                        }
                    }
                }
            }
        }
    }
}

private struct ResultsRow: View {
    @Environment(Card.self) private var card
    
    let label: String
    let scores: [Int]
    let tint: Color
    var emphasized: Bool = false
    let scorePosition: Int?

    var body: some View {
        GridRow {
            HStack(spacing: 0) {
                GridColumnRule()

                Text(label)
                    .font(emphasized ? .subheadline.bold() : .subheadline)
                    .foregroundStyle(emphasized ? .primary : .secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)

                Spacer(minLength: 0)

                GridColumnRule()
            }

            ForEach(scores.enumerated(), id: \.offset) { index, score in
                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    Text("\(score)")
                        .font(emphasized ? .body.bold() : .body)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)

                    GridColumnRule()
                }
                .background {
                    if let scorePosition {
                        let mod = scorePosition % card.players.count
                        if mod == index {
                            Color.secondary.opacity(0.2)
                        }
                    }

                    tint.opacity(emphasized ? 0.18 : 0.12)
                }
            }
        }
    }
}

private struct StepperButton: View {
    let systemImage: String
    var tint: Color = .primary
    let action: () -> Void

    @State private var repeatTask: Task<Void, Never>?
    @State private var didRepeat = false
    @State private var isPressed = false

    var body: some View {
        Image(systemName: systemImage)
            .font(.title2)
            .foregroundStyle(tint)
            .opacity(isPressed ? 0.4 : 1)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard repeatTask == nil else { return }
                        isPressed = true
                        didRepeat = false
                        startRepeating()
                    }
                    .onEnded { _ in
                        isPressed = false
                        stopRepeating()
                        if !didRepeat {
                            action()
                        }
                    }
            )
    }

    private func startRepeating() {
        repeatTask = Task {
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled else { return }
            while !Task.isCancelled {
                didRepeat = true
                action()
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    private func stopRepeating() {
        repeatTask?.cancel()
        repeatTask = nil
    }
}

private struct RoundByRoundView: View {
    @Bindable var card: Card
    @Binding var holeIndex: Int
    var topInset: CGFloat = 0

    @FocusState private var focusedPlayerIndex: Int?

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(card.hands.indices, id: \.self) { index in
                    playerList(for: card.hands[index])
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: Binding(get: { Optional(holeIndex) }, set: { holeIndex = $0 ?? holeIndex }))
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedPlayerIndex = focusedPlayerIndex.map { max(0, $0 - 1) }
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }

                Button {
                    focusedPlayerIndex = focusedPlayerIndex.map { min(card.players.count - 1, $0 + 1) }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }

                Spacer()

                Button {
                    focusedPlayerIndex = nil
                } label: {
                    Label("Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down")
                }
            }
        }
    }

    private func playerList(for hand: Card.Hand) -> some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(card.players.enumerated(), id: \.element.id) { index, player in
                        HStack(spacing: 12) {
                            PlayerImage(player: player)
                                .frame(width: 36, height: 36)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(player.name)
                                    .fontWeight(.medium)

                                Text("Total: \(card.getTotal(through: hand.number, for: player))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 12) {
                                StepperButton(systemImage: "minus.circle.fill", tint: .secondary) {
                                    let score = hand.scores[index]
                                    score.value = (score.value ?? 0) - 1
                                }

                                TextField("0", value: scoreBinding(hand: hand, index: index), format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .font(.title3.bold())
                                    .monospacedDigit()
                                    .frame(width: 44)
                                    .focused($focusedPlayerIndex, equals: index)

                                StepperButton(systemImage: "plus.circle.fill", tint: .accentColor) {
                                    let score = hand.scores[index]
                                    score.value = (score.value ?? 0) + 1
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)

                        if player.id != card.players.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .scoreCardStyle(borderOpacity: 0.15, shadowOpacity: 0.06, shadowRadius: 8, shadowY: 3)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(minHeight: max(proxy.size.height - topInset, 0), alignment: .center)
            }
            .safeAreaPadding(.top, topInset)
        }
    }

    private func scoreBinding(hand: Card.Hand, index: Int) -> Binding<Int?> {
        Binding(
            get: { hand.scores[index].value },
            set: { hand.scores[index].value = $0 }
        )
    }
}

#Preview {
    NavigationView {
        Scoresheet(card: .example)
    }
}

extension Card {
    static let example = Card(name: "New Card", players: Card_Golf_Scoresheet.Player.examples)
}
