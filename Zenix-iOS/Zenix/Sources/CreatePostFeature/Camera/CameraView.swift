import Capture
import ComposableArchitecture
import PhotosUI
import SwiftUI
import UIKit

public struct CameraView: View {
    @Bindable var store: StoreOf<CameraFeature>
    @State private var photos: [UIImage] = []

    public init(store: StoreOf<CameraFeature>) {
        self.store = store
    }
    
    public var body: some View {
        CameraPickerView(photos: $photos, isPresented: .constant(true))
//        Capture.CameraView(outputImage: $outputPhoto) { status in
//            if case .authorized = status {
//                CameraOverlay(store: store)
//            }
//        }
    }
}

private struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var photos: [UIImage]
    @Binding var isPresented: Bool

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var photos: [UIImage]
        @Binding var isPresented: Bool
        
        init(
            photos: Binding<[UIImage]>,
            isPresented: Binding<Bool>
        ) {
            _photos = photos
            _isPresented = isPresented
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                photos.append(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            photos: $photos,
            isPresented: $isPresented
        )
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraPickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        return imagePicker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<CameraPickerView>
    ) {}
}
