import ComposableArchitecture
import Entities
import Foundation

public struct ContestCardFeature: Reducer {
    public init() {}
    
    public struct State: Equatable, Identifiable {
        public var id: UUID { contest.id }
        
        let contest: Contest.List.Response
        
        public init(contest: Contest.List.Response) {
            self.contest = contest
        }
    }
    
    public enum Action {
    }
    
    public var body: some Reducer<State, Action> {
        
        EmptyReducer()
    }
}

extension Contest.List.Response {
    init() {
        self.init(
            id: UUID(),
            name: "Test",
            description: "Test descr",
            winCondition: .highScore,
            targetProfitRatio: nil,
            visibility: .public,
            currentPlayers: 2,
            maxPlayers: 5,
            minUserLevel: 0,
            instruments: [.stock],
            startDate: .now,
            endDate: .now + 7.days,
            minFund: 2000,
            status: .ready
        )
    }
}
