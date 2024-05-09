import ComposableArchitecture
import Entities
import StyleGuide
import SwiftUI
import SharedKit
import SharedViews

public struct DiscoverCardView: View, Updateable {
    @Bindable var store: StoreOf<DiscoverCardFeature>
    @State private var width: CGFloat = 0
    
    private let imageHeight: CGFloat
    
    public init(store: StoreOf<DiscoverCardFeature>, imageHeight: CGFloat? = 180) {
        self.store = store
        self.imageHeight = imageHeight ?? 180
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            AsyncZenixImage(mediaID: store.thumbnailID, size: .medium)
                .parentWidth(width)
                .frame(height: imageHeight)
                .clipped()
            
            Group {
                Text(store.post.title)
                    .font(.zenix.f2)
                    .lineLimit(2)
                
                HStack(spacing: Spacing.sp100) {
                    if let avatarID = store.avatarID {
                        AsyncZenixImage(mediaID: avatarID, size: .small)
                            .frame(width: 10, height: 10)
                            .clipShape(Circle())
                    }
                    
                    Text(store.post.user.fullName)
                        .font(.zenix.f1)
                        .lineLimit(1)
                    
                    Text(store.post.formattedCreatedAt)
                        .font(.zenix.f1)
                        .foregroundStyle(.gray.opacity(0.5))
                    
                    Spacer()
                    
                    HStack(spacing: Spacing.sp100) {
                        Image(systemName: "hand.thumbsup")
                            .font(.zenix.f2)
                        Text("\(store.post.likes)")
                            .font(.zenix.f1)
                    }
                    .padding(.bottom, Spacing.sp200)
                }
            }
            .padding(.horizontal, Spacing.sp200)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.r200))
        .onAppear {
            store.send(.onAppear)
        }
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        width = geo.size.width
                    }
            }
        }
    }
}

#Preview {
    DiscoverCardView(
        store: .init(
            initialState: .init(
                post: .mock(createdAt: .now - 100000)
            ),
            reducer: DiscoverCardFeature.init,
            withDependencies: { values in
                values.mediaClient.download = { _ in
                        .init(data: UIImage(named: "image", in: .module, with: nil)!.pngData()!)
                }
            }
        )
    )
}
