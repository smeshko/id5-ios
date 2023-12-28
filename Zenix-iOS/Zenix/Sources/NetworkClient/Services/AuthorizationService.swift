import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import Helpers
import KeychainClient

public actor AuthorizationService {
    
    private var refreshTask: Task<String, Error>?
    private let session: NetworkSession
    
    @Dependency(\.keychainClient) var keychain
    
    public init() {
        self.session = URLSession.shared
    }
    
    init(
        session: NetworkSession
    ) {
        self.session = session
    }
    
    public func validToken() async throws -> String {
#if DEBUG
        //        removeAccessToken()
#endif
        
        if let handle = refreshTask {
            return try await handle.value
        }
        
        guard let storedAccessToken = keychain.securelyRetrieveString(.accessToken),
              let payload = try? JWTDecoder.decode(jwtToken: storedAccessToken) else {
            throw NetworkError.missingToken
        }
        
        if payload.expiresAt > .now {
            return storedAccessToken
        }
        
        return try await refreshToken()
    }
    
    public func refreshToken() async throws -> String {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> String in
            defer { refreshTask = nil }
            
            guard let refreshToken = keychain.securelyRetrieveString(.refreshToken) else {
                throw NetworkError.missingToken
            }
            
            let refreshRequest = User.Token.Refresh.Request(refreshToken: refreshToken)
            let refreshData = try JSONEncoder().encode(refreshRequest)
            let endpoint = ZenixEndpoint.refresh(refreshData)
            guard let request = URLRequest.from(endpoint: endpoint) else { throw NetworkError.invalidRequest }
            
            let (data, _) = try await self.session.response(for: request)
            let tokenResponse = try JSONDecoder().decode(User.Token.Refresh.Response.self, from: data)
            
            keychain.securelyStoreString(tokenResponse.accessToken, .accessToken)
            keychain.securelyStoreString(tokenResponse.refreshToken, .refreshToken)
            
            return tokenResponse.accessToken
        }
        
        self.refreshTask = task
        
        return try await task.value
        
    }
}
//#if DEBUG
//    func removeAccessToken() {
//        keychainService.securelyStore(data: Data(), for: .accessToken)
//    }
//    
//    func saveAccessToken() {
//        let token = Token(
//            value: """
//9exPQkPANLIPkLAuNw2WxxyWkd6xVibzOAqXLmaW0gEonYuFRdM0OpR5pYTZDPZLkRyzx6Jt1+ckTdF6ewKfZMvlt05wRMGtB2zVFCs/rYj6neiK7U6KtY9diNWz7+rOXxpo4dcilFJdFJw2po+eGH+pGmLBdHVqyXbklzJseIxJAipi/YKNJDbhmKjAcerHJIN8YLyBFSvt/9hB/Ls+Y5lkT+Qt4VVnnxCbfkbgquZAd1QeK+1rB791PXDD0FbO0COFTza6ifXfE14ZJWfRj6lbBwcWezHziAv/ySU2nIAxRSBJgz5o1FVOBzVcFtNGryFuMpDBAPMknEdvTVPsbNyK5gEiAz/dFlcOB2rzYsqWJ6+CItaVtZFfFgRNYVo6pV7qxI3Kf2RIbMiTINRGLQY2TVqphnuqSVl8z9wmYYYBSvMvAmiUkGPmzj2gWl/34E2jGooR4UzCBbzQxakWyhKEH7NWxwcX6522cRVRZYxa6jBADAwYgVD5SZd3K4NLs0tICjeMluDLmhovJbPk0qt+ncTW2i9s3kSs7hlqY/uoVPBes100MQuG4LYrgoVi/JHHvlrI6WJBd8J2Z4q3heTifrH6QEdLQv5SIoi/pvCFD8qZiGu95fv6Bo3uMFYxnPDN92oMxIVrynq6VNA2qyg8OZcHWvnGVDHTN9/NNW0BEDuNo2BwkLsNzVzSAEezMaJ1X/SZrja61PDQBGe042p3s+CDPTRmd5bzMd9CXdYpB9ygeOkjpsUrmL0Eim8KjQggluhIzlp1dv7exV0+9E+Vt94btU1XuLV+hbzIpJ/pHSvUXVltMs0f9+A+t8j7wYBAUUxrKEUCzHruUWLfVDXWing4aRolEbsjgcaHWv1BcoXdu+EkzKEZYrAIsPtKs9D0IDAwwB7pgOovLfOTsfsUIt9ZpcRbSCfvTiiG97YvYNNFT9dimmAcKZjo69HNDQH30c4nW3avsx5DBGoAlbk11eSp9nf9dNVKbkm2iIg1skihURoMYUxu3/YEn0/JwZf0fRCHmGHVwuxg/NRbQ4zrDLK6hkmA9+HymxDdEddzwx5kPYitLzYHsH57A5ZEwaEAD4eq4tIE7KC6T5/WubfWlmjtRdG59N/c9Z1z1DlJZ76gBgTbEw==212FD3x19z9sWBHDJACbC00B75E
//""",
//            expirationDate: Date() + TimeInterval.years(1),
//            id: UUID()
//        )
//        
//        guard let data = token.encode() else { return }
//        keychainService.securelyStore(data: data, for: .accessToken)
//    }
//#endif
//
//}
