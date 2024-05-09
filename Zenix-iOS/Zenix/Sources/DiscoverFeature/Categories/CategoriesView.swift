import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct CategoriesView: View {
    @Bindable var store: StoreOf<CategoriesFeature>
    
    public init(store: StoreOf<CategoriesFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp300) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(store.categories) { category in
                        Button {
                            store.send(.didSelectCategory)
                        } label: {
                            VStack(alignment: .leading, spacing: Spacing.sp300) {
                                Image(systemName: category.iconName)
                                
                                Text(category.name)
                                    .lineLimit(2)
                                    .bold()
                            }
                            .font(.system(size: 16))
                            .frame(width: 100, height: 80, alignment: .topLeading)
                            .padding(Spacing.sp500)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.r200))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            ScrollView(.horizontal) {
                HStack {
                    ForEach(store.tags) { tag in
                        Button {
                            store.send(.didSelectTag(tag))
                        } label: {
                            VStack(alignment: .leading, spacing: Spacing.sp300) {
                                Text(tag.name)
                                    .lineLimit(2)
                                    .bold()
                            }
                            .font(.zenix.f2)
                            .padding(.horizontal, Spacing.sp500)
                            .padding(.vertical, Spacing.sp200)
                            .background(store.selectedTag == tag ? .green : .white)
                            .foregroundStyle(store.selectedTag == tag ? .white : .black)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    CategoriesView(
        store: .init(
            initialState: .init(),
            reducer: CategoriesFeature.init
        )
    )
}
