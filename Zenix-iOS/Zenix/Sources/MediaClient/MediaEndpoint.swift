import Endpoints
import Foundation

enum MediaEndpoint: Endpoint {
    case download(_ id: UUID)
    case upload(_ request: Data)
    
    var path: String {
        switch self {
        case .download(let id): "/api/media/download/\(id)"
        case .upload: "/api/media/upload"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .download: .get
        case .upload: .post
        }
    }
    
    var body: Data? {
        switch self {
        case .download: nil
        case .upload(let request): request
        }
    }
}

