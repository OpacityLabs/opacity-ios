#if SWIFT_PACKAGE
  import OpacityCoreObjc
#endif

public class OpacitySwiftWrapper {
  public enum Environment: Int {
    case Local = 1
    case Sandbox
    case Staging
    case Production
  }

  /// Initializes a queue by taking in dryRun and shouldShowErrorsInWebView parameters.
  /// - Parameters:
  ///   - apiKey: Your company API Key, register in the developer portal to get a hold of this
  ///   - dryRun: When true, disables disk persistence for internal functions. Useful for testing purposes.
  ///   - environment: Enum to pick an environment to run against.
  ///   - shouldShowErrorsInWebView: Controls automatic presentation of errors to the user in the in-app web view.
  ///                                If false, you must handle errors manually, including communicating to the user something has failed
  /// - Note: Once initialized, this initializer is a no-op (no operation performed).
  public static func initialize(
    apiKey: String,
    dryRun: Bool,
    environment: Environment,
    shouldShowErrorsInWebView: Bool
  ) throws {
    let environment =
      OpacityEnvironment(rawValue: environment.rawValue)
      ?? OpacityEnvironment.Production
    var error: NSError?
    let status = OpacityObjCWrapper.initialize(
      apiKey,
      andDryRun: dryRun,
      andEnvironment: environment,
      andShouldShowErrorsInWebview: shouldShowErrorsInWebView,
      andError: &error
    )

    if status != 0 {
      throw error
        ?? OpacityError(
          code: "UnkownError",
          message: "Unknown Error initializing Opacity SDK"
        )
    }
  }

  public static func initializeOpenTelemetry(
    openTelemetryEndpoint: String,
    grafanaInstanceId: String,
    grafanaApiToken: String
  ) throws {
    var error: NSError?
    let status = OpacityObjCWrapper.initializeOpenTelemetry(
      openTelemetryEndpoint,
      andGrafanaInstanceId: grafanaInstanceId,
      andGrafanaApiToken: grafanaApiToken,
      andError: &error
    )

    if status != 0 {
      throw error
        ?? OpacityError(
          code: "UnknownError",
          message: "Unknown Error initializing Open Telemetry"
        )
    }
  }

  public static func get(
    name: String,
    params: [String: Any]?
  ) async throws
    -> [String: Any]
  {
    return try await runGet(name: name, params: params, traceparent: nil, tracestate: nil)
  }

  /// Runs the flow joined to the caller's W3C trace. `traceparent` is required;
  /// `tracestate` is optional (W3C allows it to be absent).
  public static func getWithContext(
    name: String,
    params: [String: Any]?,
    traceparent: String,
    tracestate: String? = nil
  ) async throws
    -> [String: Any]
  {
    return try await runGet(
      name: name, params: params, traceparent: traceparent, tracestate: tracestate)
  }

  private static func runGet(
    name: String,
    params: [String: Any]?,
    traceparent: String?,
    tracestate: String?
  ) async throws
    -> [String: Any]
  {
    do {
      let res: [String: Any] = try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<[String: Any], Error>) in
        func resume(_ res: [AnyHashable: Any]?, _ error: Error?) {
          if let error {
            continuation.resume(throwing: error)
          } else if let res {
            continuation.resume(returning: res as! [String: Any])
          } else {
            fatalError(
              "Unreachable branch: Neither result nor error returned from OpacityObjCWrapper.get"
            )
          }
        }
        if let traceparent {
          OpacityObjCWrapper.getWithContext(
            name, andParams: params, andTraceparent: traceparent,
            andTracestate: tracestate
          ) { res, error in resume(res, error) }
        } else {
          OpacityObjCWrapper.get(name, andParams: params) { res, error in resume(res, error) }
        }
      }
      return res
    } catch let error as NSError {
      throw OpacityError(
        code: error.domain,
        message: error.localizedDescription
      )
    } catch {
      throw OpacityError(
        code: "UnknownError",
        message: error.localizedDescription
      )
    }
  }

  public static func getApiVersion() -> String {
    return OpacityObjCWrapper.getApiVersion()
  }

}
