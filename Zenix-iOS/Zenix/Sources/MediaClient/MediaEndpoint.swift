import Endpoints
import Foundation

enum MediaEndpoint: Endpoint {
    case download(_ request: Data)
    case upload(_ request: Data)
    
    var path: String {
        switch self {
        case .download: "/api/media/download"
        case .upload: "/api/media/upload"
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var body: Data? {
        switch self {
        case .download(let request): request
        case .upload(let request): request
        }
    }
}

