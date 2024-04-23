import AppAttestClient
import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import KeychainClient
import SettingsClient
import SharedKit
import TrackingClient

@Reducer
public struct AppFeature {
    public static let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: AppFeature.init
    )
    
    init() {}
    
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case metadataReceived(Metadata.Response)
    }
    
    @Dependency(\.trackingClient) var trackingClient
    @Dependency(\.networkService) var networkService
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.appAttestClient) var appAttestClient
    @Dependency(\.settingsClient) var settingsClient
    @Dependency(\.environment) var environment
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                setInitialSettings()
                trackingClient.send(.event(.applicationLaunched))
                return .run { send in
                    guard let response = try await fetchMetadata() else {
                        return
                    }
                    await send(.metadataReceived(response))
                } catch: { error, _ in
                    trackingClient.send(.error(.deviceCheckFailed))
                }
                
            case .metadataReceived(let metadata):
                keychainClient.securelyStoreString(metadata.key, .jwtKey)
            }
            return .none
        }
    }
    
    private func fetchMetadata() async throws -> Metadata.Response? {
        let keyId = try await appAttestClient.generateKey()
        let attest = try await appAttestClient.generateAttestation()
        
        guard let data = Data(base64Encoded: keyId) else {
            return nil
        }
        
        let object = Metadata.Request(
            attestation: Attestation.Verification.Request(
                attestation: attest.attestation,
                challenge: attest.challenge,
                keyID: data,
                teamID: environment.teamID,
                bundleID: environment.bundleID()
            )
        )
        
        let json = try JSONEncoder().encode(object)
        return try await networkService.sendRequest(to: ZenixEndpoint.metadata(json))
    }
    
    private func setInitialSettings() {
        if settingsClient.string(.baseURL) == nil {
            settingsClient.setValue(environment.stagingHost, .baseURL)
        }
    }
}
