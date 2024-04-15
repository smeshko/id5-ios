import ComposableArchitecture
import SwiftUI

struct CameraOverlay: View {
    @Bindable var store: StoreOf<CameraFeature>
    @Environment(\.takePicture) var takePicture

    var body: some View {
        VStack {
            HStack {
                Button(
                    action: { store.send(.dismissButtonTapped) },
                    label: {
                        Spacer()
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                )
            }
            
            Spacer()
            Button(action: { takePicture() }) {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 65, height: 65)
            }
        }
        .padding()
        .foregroundStyle(Color.white)
        .background(Color.clear)
    }
}

#Preview {
    CameraOverlay(
        store: .init(
            initialState: .init(),
            reducer: CameraFeature.init
        )
    )
}
