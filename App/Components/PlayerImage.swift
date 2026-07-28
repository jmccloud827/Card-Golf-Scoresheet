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
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .fill(player.avatarColor.gradient)

                        Text(player.avatarEmoji)
                            .font(.system(size: geometry.size.width * 0.55))
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
        .clipShape(Circle())
    }
}

#Preview {
    PlayerImage(player: .example1)
}
