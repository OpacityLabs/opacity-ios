public class OpacitySwiftWrapper {
  public static func getUberRiderProfile() throws -> (json: String, proof: String) {
    let dict = OpacityObjCWrapper.getUberRiderProfile()
    if dict == nil {
      throw OpacityError("No response from Opacity")
    }

    if let error = dict?["error"] as? String {
      throw OpacityError(error)
    }

    return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
  }

  public static func getUberRiderTripHistory(limit: Int, offset: Int) throws -> (
    json: String, proof: String
  ) {
    let dict = OpacityObjCWrapper.getUberRiderTripHistory(limit, andOffset: offset)

    if dict == nil {
      throw OpacityError("No response from Opacity")
    }

    if let error = dict?["error"] as? String {
      throw OpacityError(error)
    }

    return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
  }

  public static func getUberRiderTrip(tripId: String) throws -> (json: String, proof: String) {
    let dict = OpacityObjCWrapper.getUberRiderTrip(tripId)

    if dict == nil {
      throw OpacityError("No response from Opacity")
    }

    if let error = dict?["error"] as? String {
      throw OpacityError(error)
    }

    return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
  }

  public static func getUberDriverProfile() throws -> (json: String, proof: String) {
    let dict = OpacityObjCWrapper.getUberDriverProfile()

    if dict == nil {
      throw OpacityError("No response from Opacity")
    }

    if let error = dict?["error"] as? String {
      throw OpacityError(error)
    }

    return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
  }

  public static func getUberDriverTrips(startDate: String, endDate: String, cursor: String) throws
    -> (json: String, proof: String)
  {
    let dict = OpacityObjCWrapper.getUberDriverTrips(
      startDate, andEndDate: endDate, andCursor: cursor)

    if dict == nil {
      throw OpacityError("No response from Opacity")
    }

    if let error = dict?["error"] as? String {
      throw OpacityError(error)
    }

    return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
  }

  public static func getUberFareEstimate(
    pickupLatitude: Double, pickupLongitude: Double, destinationLatitude: Double,
    destinationLongitude: Double
  ) throws -> (json: String, proof: String) {
    let dict = OpacityObjCWrapper.getUberFareEstimate(
      pickupLatitude as NSNumber,
      andPickupLongitude: pickupLongitude as NSNumber,
      andDestinationLatitude: destinationLatitude as NSNumber,
      andDestinationLongitude: destinationLongitude as NSNumber)

    if dict == nil {
      throw OpacityError("No response from Opacity")
    }

    if let error = dict?["error"] as? String {
      throw OpacityError(error)
    }

    return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
  }
    
    public static func getRedditAccount() throws -> (json: String, proof: String)  {
        let dict = OpacityObjCWrapper.getRedditAccount()
        
        if dict == nil {
            throw OpacityError("No response from Opacity")
        }
        
        if let error = dict?["error"] as? String {
            throw OpacityError(error)
        }
        
        return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
    }
    
    public static func getRedditFollowedSubreddits() throws -> (json: String, proof: String)  {
        let dict = OpacityObjCWrapper.getRedditFollowedSubreddits()
        
        if dict == nil {
            throw OpacityError("No response from Opacity")
        }
        
        if let error = dict?["error"] as? String {
            throw OpacityError(error)
        }
        
        return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
    }
    
    public static func getRedditComments() throws -> (json: String, proof: String)  {
            let dict = OpacityObjCWrapper.getRedditComments()
            
            if dict == nil {
                throw OpacityError("No response from Opacity")
            }
            
            if let error = dict?["error"] as? String {
                throw OpacityError(error)
            }
            
            return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
        }
    
    public static func getRedditPosts() throws -> (json: String, proof: String)  {
            let dict = OpacityObjCWrapper.getRedditPosts()
            
            if dict == nil {
                throw OpacityError("No response from Opacity")
            }
            
            if let error = dict?["error"] as? String {
                throw OpacityError(error)
            }
            
            return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
        }
    
    public static func getZabkaAccount() throws -> (json: String, proof: String)  {
            let dict = OpacityObjCWrapper.getZabkaAccount()
            
            if dict == nil {
                throw OpacityError("No response from Opacity")
            }
            
            if let error = dict?["error"] as? String {
                throw OpacityError(error)
            }
            
            return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
        }
    
    public static func getZabkaPoints() throws -> (json: String, proof: String)  {
               let dict = OpacityObjCWrapper.getZabkaPoints()
               
               if dict == nil {
                   throw OpacityError("No response from Opacity")
               }
               
               if let error = dict?["error"] as? String {
                   throw OpacityError(error)
               }
               
               return (json: dict!["json"] as! String, proof: dict!["proof"] as! String)
           }
}
