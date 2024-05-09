import Dependencies
import Entities
import MediaClient
import StyleGuide
import SwiftUI

public struct AsyncZenixImage: View, Updateable {
    public enum Size {
        case small, medium, original
        var remote: Media.Size {
            switch self {
            case .small: .s
            case .medium: .m
            case .original: .o
            }
        }
    }
    
    enum LoadingState: Equatable {
        case done(Image)
        case loading
        case error
    }
    
    private let mediaID: UUID
    private let size: Size
    @State private var loadingState: LoadingState = .loading
    private var width: CGFloat?
    @Dependency(\.mediaClient) private var mediaClient
    
    public init(mediaID: UUID, size: Size = .original) {
        self.mediaID = mediaID
        self.size = size
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
                    .clipShape(Rectangle())

            case .error:
                Image(systemName: "xmark.icloud")
                    .foregroundStyle(.red)
            }
        }
        .frame(width: width)
        .clipped()
        .onAppear {
            Task {
                try await loadImage()
            }
        }
    }
    
    private func loadImage() async throws {
        if case .done(_) = loadingState {
            return
        }
        
        loadingState = .loading
        do {
            let request = Media.Download.Request(id: mediaID, size: size.remote)
            let response = try await mediaClient.download(request)
            let image = Image(uiImage: .init(data: response.data) ?? .init())
            loadingState = .done(image)
        } catch {
            loadingState = .error
        }
    }
    
    public func parentWidth(_ width: CGFloat) -> Self {
        update(\.width, value: width)
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
