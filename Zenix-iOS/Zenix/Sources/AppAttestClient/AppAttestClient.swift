import ComposableArchitecture
import CryptoKit
import DeviceCheck
import KeychainClient
import NetworkClient
import Endpoints
import Entities

public enum AppAttestError: Error {
    case generic(Error)
    case generatingKeyFailed
    case generatingAttestationFailed
}

public struct AppAttestClient {
    public var isSupported: () -> Bool
    public var generateKey: () async throws -> String
    public var generateAttestation: () async throws -> (attestation: Data, challenge: String)
}

public extension AppAttestClient {
    static let live: AppAttestClient = {
        @Dependency(\.keychainClient) var keychain
        @Dependency(\.networkService) var networkService
        let service = DCAppAttestService.shared

        return .init(
            isSupported: {
                service.isSupported
            },
            generateKey: {
                if let keyId = keychain.securelyRetrieveString(.attestKeyId) {
                    return keyId
                }
                
                return try await withCheckedThrowingContinuation { continuation in
                    service.generateKey { keyId, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        guard let keyId else {
                            continuation.resume(throwing: AppAttestError.generatingKeyFailed)
                            return
                        }
                        
                        keychain.securelyStoreString(keyId, .attestKeyId)
                        continuation.resume(returning: keyId)
                    }
                }
            },
            generateAttestation: {
                guard let keyId = keychain.securelyRetrieveString(.attestKeyId) else {
                    throw AppAttestError.generatingAttestationFailed
                }
                
                let challenge: Attestation.Challenge.Response = try await networkService.sendRequest(to: MetadataEndpoint.challenge)
                guard let data = Data(base64Encoded: challenge.value) else {
                    throw AppAttestError.generatingAttestationFailed
                }
                let challengeHash = Data(SHA256.hash(data: data))

                return try await withCheckedThrowingContinuation { continuation in
                    service.attestKey(keyId, clientDataHash: challengeHash) { attestation, error in
                        if let attestationValue = attestation {
                            continuation.resume(returning: (attestationValue, challenge.value))
                        } else if let dcError = error as? DCError, dcError.code == .invalidKey {
                            keychain.delete(.attestKeyId)
                            continuation.resume(throwing: AppAttestError.generatingAttestationFailed)
                        } else {
                            continuation.resume(throwing: AppAttestError.generatingAttestationFailed)
                        }
                    }
                }
            }
        )
    }()
}

public extension AppAttestClient {
    static let preview: AppAttestClient = {
        .init(
            isSupported: { true },
            generateKey: { "key" },
            generateAttestation: { (Data(), "challenge") }
        )
    }()
}

private enum AppAttestClientKey: DependencyKey {
    static let liveValue = AppAttestClient.live
    static var previewValue = AppAttestClient.preview
}

public extension DependencyValues {
    var appAttestClient: AppAttestClient {
        get { self[AppAttestClientKey.self] }
        set { self[AppAttestClientKey.self] = newValue }
    }
}
