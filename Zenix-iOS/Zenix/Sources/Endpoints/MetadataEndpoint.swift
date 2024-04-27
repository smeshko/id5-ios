import Foundation

public enum MetadataEndpoint: Endpoint {
    
    case metadata(_ attest: Data)
    case challenge
    
    public var path: String {
        switch self {
        case .challenge: "/api/metadata/challenge"
        case .metadata: "/api/metadata"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .metadata: .post
        case .challenge: .get
        }
    }
    
    public var body: Data? {
        switch self {
        case .metadata(let attest): attest
        default: nil
        }
    }
}
