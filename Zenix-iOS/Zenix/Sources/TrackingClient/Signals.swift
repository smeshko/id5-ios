public extension TrackingClient.Signal {
    enum Event: String {
        case applicationLaunched
    }
    
    enum Error: String {
        case deviceCheckFailed
    }
    
    enum View: String {
        case myProfile
    }
}
