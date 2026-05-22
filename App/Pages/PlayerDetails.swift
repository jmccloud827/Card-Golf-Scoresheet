import SwiftData
import SwiftUI

struct PlayerDetails: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var player: Player

    var body: some View {
        List {
            PlayerLabelEditor(player: player)
            
            if !player.completedGames.isEmpty {
                Section("Stats") {
                    LabeledContent {
                        Text(player.averageScore, format: .number.precision(.fractionLength(2)))
                    } label: {
                        Text("Average Score: ")
                    }
                    
                    LabeledContent {
                        Text(player.bestScore, format: .number)
                    } label: {
                        Text("Best Game: ")
                    }
                    
                    LabeledContent {
                        Text(player.worstScore, format: .number)
                    } label: {
                        Text("Worst Game: ")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
                
            ToolbarItem {
                Button(role: .confirm) {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let _ = Game.examples
    PlayerDetails(player: .example1)
}
