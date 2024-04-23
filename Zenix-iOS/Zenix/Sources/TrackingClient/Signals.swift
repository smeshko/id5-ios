public extension TrackingClient.Signal {
    enum Event: String {
        case applicationLaunched
        
        // auth
        case signInRequested
        case signUpRequested
        case appleAuthRequested
        case forgotPasswordRequested
        case authSuccessful
    }
    
    enum Error: String {
        case deviceCheckFailed
        case signInFailed
        case signUpFailed
        case appleAuthFailed
    }
    
    enum NonFatal: String {
        case appleAuthWrongCredentialReturned
    }
    
    enum View: String {
        case auth
        case myProfile
    }
}
