import Foundation

public enum MediaEndpoint: Endpoint {
    case download(_ id: UUID)
    
    public var path: String {
        switch self {
        case .download(let id): "/api/media/download/\(id)"
        }
    }
}
