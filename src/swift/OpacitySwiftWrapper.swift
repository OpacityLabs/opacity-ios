#if SWIFT_PACKAGE
    import OpacityCoreObjc
#endif

public class OpacitySwiftWrapper {
    public enum Environment: Int {
        case Test = 0
        case Local
        case Staging
        case Production
    }

    /// Initializes a queue by taking in dryRun and shouldShowErrorsInWebView parameters.
    /// - Parameters:
    ///   - dryRun: When true, disables disk persistence for internal functions. Useful for testing purposes.
    ///   - shouldShowErrorsInWebView: Controls automatic presentation of errors to the user in the in-app web view.
    ///                                If false, you must handle errors manually, including communicating to the user something has failed
    /// - Note: Once initialized, this initializer is a no-op (no operation performed).
    public static func initialize(
        apiKey: String, dryRun: Bool, environment: Environment,
        shouldShowErrorsInWebView: Bool
    ) throws {
        let environment =
            OpacityEnvironment(rawValue: environment.rawValue)
            ?? OpacityEnvironment.Production
        let status = OpacityObjCWrapper.initialize(
            apiKey, andDryRun: dryRun,
            andEnvironment: environment,
            andShouldShowErrorsInWebview: shouldShowErrorsInWebView)

        if status != 0 {
            throw OpacityError("Failed to initialize the SDK")
        }
    }

    public static func get(name: String, params: [String: Any]?) async throws
        -> [String: Any]
    {
        return try await withCheckedThrowingContinuation { continuation in
            OpacityObjCWrapper.get(name, andParams: params) { (res, error) in
                if let error {
                    continuation.resume(throwing: error)
                } else if let res {
                    continuation.resume(returning: res as! [String: Any])
                }
            }
        }
    }

}
