import ComposableArchitecture
import Entities

public struct Category: Equatable, Identifiable {
    public var id: String { name }
    
    let iconName: String
    let name: String
}

public struct Tag: Equatable, Identifiable {
    public var id: String { name }
    let name: String
}

@Reducer
public struct CategoriesFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var categories: [Category]
        var tags: [Tag]
        var selectedTag: Tag?
        
        public init(
            categories: [Category] = [],
            tags: [Tag] = []
        ) {
            self.categories = categories
            self.tags = tags
        }
    }
    
    public enum Action {
        case onAppear
        case didSelectCategory
        case didSelectTag(Tag)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.categories = [
                    .init(iconName: "takeoutbag.and.cup.and.straw", name: "Dinner under $25"),
                    .init(iconName: "wrench.and.screwdriver", name: "Local Services"),
                    .init(iconName: "seal", name: "Fresh Produce"),
                    .init(iconName: "bag", name: "Costco Deals")
                ]
                
                state.tags = [
                    .init(name: "All"),
                    .init(name: "Follow"),
                    .init(name: "Grocery"),
                    .init(name: "Organic food"),
                    .init(name: "Restaurant"),
                    .init(name: "Home Kitchen")
                ]
                
                state.selectedTag = state.tags.first
                
            case .didSelectTag(let tag):
                state.selectedTag = tag
                
            case .didSelectCategory:
                break
            }
            
            return .none
        }
    }
}
