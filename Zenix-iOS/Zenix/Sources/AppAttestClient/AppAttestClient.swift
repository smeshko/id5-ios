import ComposableArchitecture
import CryptoKit
import DeviceCheck
import KeychainClient

public enum AppAttestError: Error {
    case generic(Error)
    case generatingKeyFailed
    case generatingAttestationFailed
}

public struct AppAttestClient {
    var isSupported: () -> Bool
    var generateKey: () async throws -> String
    var generateAttestation: (String, Data) async throws -> Data
}

public extension AppAttestClient {
    static let live: AppAttestClient = {
        @Dependency(\.keychainClient) var keychain
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
            generateAttestation: { keyId, challenge in
                let challengeHash = Data(SHA256.hash(data: challenge))

                return try await withCheckedThrowingContinuation { continuation in
                    service.attestKey(keyId, clientDataHash: challengeHash) { attestation, error in
                        if let attestationValue = attestation {
                            continuation.resume(returning: attestationValue)
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
