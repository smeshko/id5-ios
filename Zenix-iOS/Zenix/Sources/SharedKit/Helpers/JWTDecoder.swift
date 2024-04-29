import Dependencies
import Entities
import Foundation
import JWTKit
import KeychainClient

public struct JWTDecoder {
    @Dependency(\.keychainClient) private var keychainClient
    
    public enum Error: Swift.Error {
        case expired
        case verificationFailed
    }
    
    public init() {}
    
    public func decode(jwtToken jwt: String) throws -> Payload? {
        let signers = JWTSigners()
//        var payload: Payload?
        
//        #if DEBUG
        return try? signers.unverified(jwt)
//        #else
//        guard let key = keychainClient.securelyRetrieveString(.jwtKey) else {
//            return nil
//        }
//        
//        signers.use(.hs256(key: key))
//
//        do {
//            payload = try signers.verify(jwt, as: Payload.self)
//        } catch JWTKit.JWTError.claimVerificationFailure(_, let reason) where reason == "expired" {
//            throw Error.expired
//        } catch {
//            throw Error.verificationFailed
//        }
//        return payload
//        #endif
    }
}
