import SwiftData
import SwiftUI

struct PlayerLabel: View {
    let player: Player
    var size = 100.0
    var isVertical = false

    var body: some View {
        if isVertical {
            VStack {
                image
                
                name
            }
        } else {
            HStack {
                image
                
                name
            }
        }
    }
    
    @ViewBuilder private var image: some View {
        PlayerImage(player: player)
            .frame(width: size, height: size)
    }
    
    private var name: some View {
        Text(player.name)
    }
    
    func vertical() -> Self {
        var result = self
        result.isVertical = true
        return result
    }
}

#Preview {
    PlayerLabel(player: .example1)
}
