import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            Image(systemName: "suit.spade.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.white)
                    .frame(width: 300, height: 300)
                .padding()
                .padding()
                .padding()
                .padding()
                .background(.accent.gradient)
        }
        .modelContainer(for: Game.self)
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
