import OpacityCore

func testOpacity() {
//    Do not call this functions on the main thread as they will block your UI
  DispatchQueue.global(qos: .background).async {
    do {
      let (json, proof) = try OpacitySwiftWrapper.getUberRiderProfile()
      
        let (json2, proof2) = try OpacitySwiftWrapper.getUberRiderTripHistory(limit: 21, offset: 19);
        
        var (json3, proof3) = try OpacitySwiftWrapper.getUberFareEstimate(pickupLatitude: 10.0, pickupLongitude: 10.0, destinationLatitude: 11.0, destinationLongitude: 11.0)
    } catch {
      DispatchQueue.main.async {
        print("Error: \(error)")
      }
    }
  }

}
