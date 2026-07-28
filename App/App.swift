import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            CardsList()
        }
        .modelContainer(.appContainer)
    }
}

extension ModelContainer {
    static var appContainer: ModelContainer {
        let container = try! ModelContainer(for: Card.self, Player.self)

        #if DEBUG
        let context = container.mainContext
        let existingCardCount = (try? context.fetchCount(FetchDescriptor<Card>())) ?? 0
        if existingCardCount == 0 {
            for player in Player.examples {
                context.insert(player)
            }

            for card in Card.examples {
                context.insert(card)
            }

            try? context.save()
        }
        #endif

        return container
    }

    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Card.self, Player.self,
                                            configurations: config)
        
        for player in Player.examples {
            container.mainContext.insert(player)
        }
        
        for card in Card.examples {
            container.mainContext.insert(card)
        }
    
        try? container.mainContext.save()
    
        return container
    }
}

/// App Icon
#Preview {
    Image(systemName: "suit.spade.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.white)
            .frame(width: 250, height: 250)
        .padding()
        .padding()
        .padding(44)
        .background(.accent.gradient)
}
