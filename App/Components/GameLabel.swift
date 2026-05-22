import SwiftData
import SwiftUI

struct GameLabel: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: game.finished != nil ? "checkmark.circle.fill" : "repeat.circle.fill")
                    .foregroundStyle(game.finished != nil ? .green : .accent)
                
                Text(game.name)
             }
            .font(.title2)
            
            Group {
                HStack {
                    Text("Started: ")
                    
                    Text(game.created.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.gray)
                }
                
                if game.finished != nil {
                    HStack {
                        Text("Winner: ")
                        
                        HStack(spacing: 0) {
                            PlayerLabel(player: game.winner, size: 25)
                            
                            Text(" (\(game.getTotal(for: game.winner)))")
                        }
                        .foregroundStyle(.gray)
                    }
                }
            }
            .font(.caption)
        }
    }
}

#Preview {
    GameLabel(game: .example1)
}
