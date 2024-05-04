import Endpoints
import Foundation

enum PostEndpoint: Endpoint {

    case allPosts
    case postDetails(_ id: UUID)
    case createPost(_ request: Data)
    
    case createComment(_ text: Data, _ post: UUID)
    case commentsForPost(_ post: UUID)
    
    var path: String {
        switch self {
        case .allPosts: "/api/posts/all"
        case .postDetails(let id): "/api/posts/\(id)"
        case .createPost: "/api/posts/create"
            
        case .createComment(_, let id): "/api/comments/post/\(id)"
        case .commentsForPost(let id): "/api/comments/all/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .allPosts, .postDetails, .commentsForPost: .get
        case .createComment, .createPost: .post
        }
    }
    
    var body: Data? {
        switch self {
        case .createComment(let text, _): text
        case .createPost(let request): request
        default: nil
        }
    }
}
