import Foundation

public enum ServiceEndpoint: Endpoint {
    case nearbyLocations(_ lon: Double, _ lat: Double)
    case addressAutocomplete(_ query: String)
    case geocode(_ id: String)
    
    var base: String { "/api/services/places" }

    public var path: String {
        switch self {
        case .nearbyLocations: "\(base)/search"
        case .addressAutocomplete: "\(base)/autocomplete"
        case .geocode: "\(base)/geocode"
        }
    }
    
    public var queryParameters: [String : String]? {
        switch self {
        case .nearbyLocations(let lon, let lat):
            return ["latitude": "\(lat)", "longitude": "\(lon)"]
        case .addressAutocomplete(let query):
            return ["query": query]
        case .geocode(let id):
            return ["placeId": id]
        }
    }
}
