import Entities
import SwiftUI

public struct ZenixImage: View {
    private let media: Media.Download.Response?
    
    public init(media: Media.Download.Response?) {
        self.media = media
    }
    
    public var body: some View {
        Image(uiImage: .init(data: media?.data ?? Data()) ?? .init())
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
