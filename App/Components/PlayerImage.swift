import SwiftData
import SwiftUI

struct PlayerImage: View {
    let player: Player

    var body: some View {
        Group {
            if let photoData = player.picture,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .clipShape(Circle())
    }
}

#Preview {
    PlayerImage(player: .example1)
}
