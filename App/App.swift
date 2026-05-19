import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            GamesList()
        }
        .modelContainer(for: Game.self)
    }
}

/// App Icon
#Preview {
    Image(systemName: "document.viewfinder")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.white)
            .frame(width: 300, height: 300)
        .padding()
        .padding()
        .padding()
        .padding()
        .background(Color("Color").gradient)
}
