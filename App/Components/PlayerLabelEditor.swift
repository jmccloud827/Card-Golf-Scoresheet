import PhotosUI
import SwiftUI

struct PlayerLabelEditor: View {
    @Bindable var player: Player
    
    @State private var photo: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showDialog = false
    
    var body: some View {
        HStack {
            Button {
                showDialog = true
            } label: {
                image
                    .frame(width: 75, height: 75)
                    .foregroundStyle(.foreground)
            }
                
            TextField("Name", text: $player.name)
             
            label
        }
        .fullScreenCover(isPresented: $showCamera) {
            cameraView
        }
    }
    
    private var label: some View {
        HStack {
            VStack {
                Button("Camera") {
                    showCamera = true
                }
                .buttonStyle(.borderedProminent)
                
                PhotosPicker("Library", selection: $photo, matching: .images)
                    .buttonStyle(.borderedProminent)
                    .onChange(of: photo) {
                        Task {
                            if let loaded = try? await photo?.loadTransferable(type: Data.self) {
                                withAnimation {
                                    player.picture = loaded
                                }
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder private var image: some View {
        PlayerImage(player: player)
    }
    
    private var cameraView: some View {
        CameraView(sourceType: .camera) { uiImage in
            withAnimation {
                player.picture = uiImage?.pngData()
            }
        }
        .ignoresSafeArea()
    }
}

private struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    var sourceType: UIImagePickerController.SourceType
    var onDidFinish: (UIImage?) -> Void = { _ in }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

private class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: CameraView
    
    init(parent: CameraView) {
        self.parent = parent
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        self.parent.onDidFinish(selectedImage)
        self.parent.dismiss()
    }
}

#Preview {
    List {
        PlayerLabelEditor(player: .example1)
    }
}
