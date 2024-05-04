import Dependencies
import Entities
import MediaClient
import SwiftUI

public struct AsyncZenixImage: View {
    enum LoadingState: Equatable {
        case done(Image)
        case loading
        case error
    }
    
    private let mediaID: UUID
    @State private var loadingState: LoadingState = .loading
    @Dependency(\.mediaClient) private var mediaClient
    
    public init(mediaID: UUID) {
        self.mediaID = mediaID
    }
    
    public var body: some View {
        VStack {
            switch loadingState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.gray)
                
            case .done(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                
            case .error:
                Image(systemName: "xmark.icloud")
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            Task {
                try await loadImage()
            }
        }
    }
    
    private func loadImage() async throws {
        loadingState = .loading
        do {
            let response = try await mediaClient.download(mediaID)
            let image = Image(uiImage: .init(data: response.data) ?? .init())
            loadingState = .done(image)
        } catch {
            loadingState = .error
        }
    }
}

#Preview("Dynamic") {
    AsyncZenixImage(
        mediaID: withDependencies({ values in
            values.mediaClient.download = { _ in
                try await Task.sleep(for: .seconds(3))
                return .init(data: UIImage(named: "image", in: .module, with: nil)!.pngData()!)
            }
        }, operation: {
            UUID.init()
        })
    )
    .frame(width: 150, height: 150)
}
