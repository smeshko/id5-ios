import Dependencies
import Entities
import Foundation
import JWTKit
import KeychainClient

public struct JWTDecoder {
    @Dependency(\.keychainClient) private var keychainClient
    
    public enum JWTError: Error {
        case expired
        case verificationFailed
    }
    
    public init() {}
    
    public func decode(jwtToken jwt: String) throws -> Payload? {
        guard let key = keychainClient.securelyRetrieveString(.jwtKey) else {
            return nil
        }
        
        let signers = JWTSigners()
        signers.use(.hs256(key: key))

        var payload: Payload?
        
        do {
            payload = try signers.verify(jwt, as: Payload.self)
        } catch JWTKit.JWTError.claimVerificationFailure(_, let reason) where reason == "expired" {
            return nil
        } catch {
            throw JWTError.verificationFailed
        }
        return payload
    }
}
