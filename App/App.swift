import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            GamesList()
        }
        .modelContainer(for: [Game.self, Player.self])
    }
}

extension ModelContainer {
    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Game.self, Player.self,
                                            configurations: config)
        
        for player in Player.examples {
            container.mainContext.insert(player)
        }
        
        for game in Game.examples {
            container.mainContext.insert(game)
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
