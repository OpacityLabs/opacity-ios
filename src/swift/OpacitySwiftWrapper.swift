public class OpacitySwiftWrapper {
  public enum Environment: Int {
    case Test = 0
    case Local
    case Staging
    case Production
  }

  public static func initialize(apiKey: String, dryRun: Bool, environment: Environment) throws {
    let status = OpacityObjCWrapper.initialize(
      apiKey, andDryRun: dryRun,
      andEnvironment: OpacityEnvironment(rawValue: environment.rawValue)
        ?? OpacityEnvironment.Production)
    if status != 0 {
      throw OpacityError("Failed to initialize the SDK")
    }
  }

  public static func getUberRiderProfile() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getUberRiderProfile { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getUberRiderTripHistory(cursor: String) async throws -> (
    json: String, proof: String?
  ) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getUberRiderTripHistory(cursor) { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getUberRiderTrip(tripId: String) async throws -> (json: String, proof: String?)
  {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getUberRiderTrip(tripId) { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getUberDriverProfile() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getUberDriverProfile { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getUberDriverTrips(startDate: String, endDate: String, cursor: String)
    async throws
    -> (json: String, proof: String?)
  {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getUberDriverTrips(startDate, andEndDate: endDate, andCursor: cursor) {
        (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getUberFareEstimate(
    pickupLatitude: Double, pickupLongitude: Double, destinationLatitude: Double,
    destinationLongitude: Double
  ) async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getUberFareEstimate(
        pickupLatitude as NSNumber, andPickupLongitude: pickupLongitude as NSNumber,
        andDestinationLatitude: destinationLatitude as NSNumber,
        andDestinationLongitude: destinationLongitude as NSNumber
      ) { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getRedditAccount() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getRedditAccount { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getRedditFollowedSubreddits() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getRedditFollowedSubreddits { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getRedditComments() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getRedditComments { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getRedditPosts() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getRedditPosts { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getZabkaAccount() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getZabkaAccount { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getZabkaPoints() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getZabkaPoints { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  // Carta
  public static func getCartaProfile() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getCartaProfile { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getCartaOrganizations() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getCartaOrganizations { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getCartaPortfolioInvestments(firmId: String, accountId: String) async throws
    -> (json: String, proof: String?)
  {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getCartaPortfolioInvestments(firmId, andAccountId: accountId) {
        (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getCartaHoldingsCompanies(accountId: String) async throws -> (
    json: String, proof: String?
  ) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getCartaHoldingsCompanies(accountId) { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getCartaCorporationSecurities(accountId: String, corporationId: String)
    async throws
    -> (json: String, proof: String?)
  {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getCartaCorporationSecurities(accountId, andCorporationId: corporationId) {
        (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  // github
  public static func getGithubProfile() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getGithubProfile { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  // instagram
  public static func getInstagramProfile() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getInstagramProfile { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getInstagramLikes() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getInstagramLikes { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getInstagramComments() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getInstagramComments { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

  public static func getInstagramSavedPosts() async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.getInstagramSavedPosts { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }

    public static func get(name: String) async throws -> (json: String, proof: String?) {
    return try await withCheckedThrowingContinuation { continuation in
      OpacityObjCWrapper.get(name) { (json, proof, error) in
        if let error {
          continuation.resume(throwing: error)
        } else if let json {
          continuation.resume(returning: (json, proof))
        }
      }
    }
  }
}
