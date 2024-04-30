import Foundation

public enum MediaEndpoint: Endpoint {
    case download(_ id: UUID)
    case upload(_ request: Data)
    
    public var path: String {
        switch self {
        case .download(let id): "/api/media/download/\(id)"
        case .upload: "/api/media/upload"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .download: .get
        case .upload: .post
        }
    }
    
    public var body: Data? {
        switch self {
        case .download: nil
        case .upload(let request): request
        }
    }
}
