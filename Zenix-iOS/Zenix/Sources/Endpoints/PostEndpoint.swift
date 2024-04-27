import Foundation

public enum PostEndpoint: Endpoint {

    case allPosts
    case postDetails(_ id: UUID)
    
    case createComment(_ text: Data, _ post: UUID)
    case commentsForPost(_ post: UUID)
    
    public var path: String {
        switch self {
        case .allPosts: "/api/posts/all"
        case .postDetails(let id): "/api/posts/\(id)"
            
        case .createComment(_, let id): "/api/comments/post/\(id)"
        case .commentsForPost(let id): "/api/comments/all/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .allPosts, .postDetails, .commentsForPost: .get
        case .createComment: .post
        }
    }
    
    public var body: Data? {
        switch self {
        case .createComment(let text, _): text
        default: nil
        }
    }
}
