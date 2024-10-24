import CoreLocation
import OpacityCore
import UIKit

class MainViewController: UIViewController {
  var riderProfileLabel: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let env = loadEnvFile(), let apiKey = env["OPACITY_API_KEY"] else {
      print("Error loading .env file or API key not found")
      return
    }

    do {
      try OpacitySwiftWrapper.initSDK(apiKey: apiKey, dryRun: false)
      print("🟩 Opacity SDK initialized successfully")
    } catch {
      print("Error initializing SDK: \(error)")
    }

    let uberProfileButton = UIButton(type: .system)
    uberProfileButton.setTitle("Uber get rider profile", for: .normal)
    uberProfileButton.addTarget(
      self, action: #selector(getRiderProfileWrapper), for: .touchUpInside)
    uberProfileButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
    view.addSubview(uberProfileButton)

    let riderProfileLabel = UILabel(frame: CGRect(x: 100, y: 200, width: 200, height: 50))
    riderProfileLabel.text = "Waiting..."
    riderProfileLabel.textAlignment = .center
    view.addSubview(riderProfileLabel)
    self.riderProfileLabel = riderProfileLabel
    //
    //    let uberRiderHistoryButton = UIButton(type: .system)
    //    uberRiderHistoryButton.setTitle("uber rider trip history", for: .normal)
    //    uberRiderHistoryButton.addTarget(
    //      self, action: #selector(getUberRiderTripHistory), for: .touchUpInside)
    //    uberRiderHistoryButton.frame = CGRect(x: 100, y: 350, width: 200, height: 50)
    //    view.addSubview(uberRiderHistoryButton)
    //
    //    let uberTripButton = UIButton(type: .system)
    //    uberTripButton.setTitle("uber rider trip", for: .normal)
    //    uberTripButton.addTarget(self, action: #selector(getUberRiderTrip), for: .touchUpInside)
    //    uberTripButton.frame = CGRect(x: 100, y: 400, width: 200, height: 50)
    //    view.addSubview(uberTripButton)
    //
    //    let uberDriverProfileButton = UIButton(type: .system)
    //    uberDriverProfileButton.setTitle("GET Uber driver profile", for: .normal)
    //    uberDriverProfileButton.addTarget(
    //      self, action: #selector(getUberDriverProfile), for: .touchUpInside)
    //    uberDriverProfileButton.frame = CGRect(x: 100, y: 450, width: 200, height: 50)
    //    view.addSubview(uberDriverProfileButton)
    //
    //    let uberDriverTripsButton = UIButton(type: .system)
    //    uberDriverTripsButton.setTitle("uber driver trips", for: .normal)
    //    uberDriverTripsButton.addTarget(
    //      self, action: #selector(getUberDriverTrips), for: .touchUpInside)
    //    uberDriverTripsButton.frame = CGRect(x: 100, y: 500, width: 200, height: 50)
    //    view.addSubview(uberDriverTripsButton)
    //
    //    let zabkaProfileButton = UIButton(type: .system)
    //    zabkaProfileButton.setTitle("zabka Profile", for: .normal)
    //    zabkaProfileButton.addTarget(self, action: #selector(getZabkaProfile), for: .touchUpInside)
    //    zabkaProfileButton.frame = CGRect(x: 100, y: 550, width: 200, height: 50)
    //    view.addSubview(zabkaProfileButton)
    //
    //    let getRedditAccountButton = UIButton(type: .system)
    //    getRedditAccountButton.setTitle("reddit account", for: .normal)
    //    getRedditAccountButton.addTarget(self, action: #selector(getRedditProfile), for: .touchUpInside)
    //    getRedditAccountButton.frame = CGRect(x: 100, y: 600, width: 200, height: 50)
    //    view.addSubview(getRedditAccountButton)
  }

  func loadEnvFile() -> [String: String]? {
    guard let filePath = Bundle.main.path(forResource: ".env", ofType: nil) else {
      print("Error finding .env file")
      return nil
    }

    do {
      let content = try String(contentsOfFile: filePath, encoding: .utf8)
      var envVariables = [String: String]()
      let lines = content.split(separator: "\n")

      for line in lines {
        let keyValuePair = line.split(separator: "=")
        if keyValuePair.count == 2 {
          let key = keyValuePair[0].trimmingCharacters(in: .whitespaces)
          let value = keyValuePair[1].trimmingCharacters(in: .whitespaces)
          envVariables[key] = value
        }
      }

      return envVariables
    } catch {
      print("Error reading .env file: \(error.localizedDescription)")
      return nil
    }
  }

  @objc func getRiderProfileWrapper() {
    Task {
      await getRiderProfile()
    }
  }

  func getRiderProfile() async {
    do {
      let (json, _) = try await OpacitySwiftWrapper.getUberRiderProfile()
      self.riderProfileLabel?.text = "Success"
    } catch {
      self.riderProfileLabel?.text = "Failed"
      print("Error: \(error)")
    }
  }
  //
  //  @objc func getUberRiderTripHistory() {
  //    DispatchQueue.global(qos: .default).async {
  //      var json: UnsafeMutablePointer<CChar>?
  //      var proof: UnsafeMutablePointer<CChar>?
  //      var err: UnsafeMutablePointer<CChar>?
  //
  //      let status = opacity_core.get_uber_rider_trip_history(nil, &json, &proof, &err)
  //      if status != opacity_core.OPACITY_OK {
  //        let errorMessage = String(cString: err!)
  //        print("Error: \(errorMessage)")
  //        return
  //      }
  //
  //      let data = String(cString: json!)
  //      print("Uber rider trip history: \(data)")
  //    }
  //  }
  //
  //  @objc func getUberRiderTrip() {
  //    DispatchQueue.global(qos: .default).async {
  //      var json: UnsafeMutablePointer<CChar>?
  //      var proof: UnsafeMutablePointer<CChar>?
  //      var err: UnsafeMutablePointer<CChar>?
  //
  //      let status = opacity_core.get_uber_rider_trip(
  //        "c7427573-0ea5-46a9-a9c5-e286efc31ff5", &json, &proof, &err)
  //      if status != opacity_core.OPACITY_OK {
  //        let errorMessage = String(cString: err!)
  //        print("Error: \(errorMessage)")
  //        return
  //      }
  //
  //      let data = String(cString: json!)
  //      print("data: \(data)")
  //    }
  //  }
  //
  //  @objc func getUberDriverProfile() {
  //    DispatchQueue.global(qos: .default).async {
  //      var json: UnsafeMutablePointer<CChar>?
  //      var proof: UnsafeMutablePointer<CChar>?
  //      var err: UnsafeMutablePointer<CChar>?
  //
  //      let status = opacity_core.get_uber_driver_profile(&json, &proof, &err)
  //      if status != opacity_core.OPACITY_OK {
  //        let errorMessage = String(cString: err!)
  //        print("Error: \(errorMessage)")
  //        return
  //      }
  //
  //      let data = String(cString: json!)
  //      print(" \(data)")
  //    }
  //  }
  //
  //  @objc func getUberDriverTrips() {
  //    DispatchQueue.global(qos: .default).async {
  //      var json: UnsafeMutablePointer<CChar>?
  //      var proof: UnsafeMutablePointer<CChar>?
  //      var err: UnsafeMutablePointer<CChar>?
  //
  //      let status = opacity_core.get_uber_driver_trips(
  //        "2024-01-01", "2024-07-31", "", &json, &proof, &err)
  //      if status != opacity_core.OPACITY_OK {
  //        let errorMessage = String(cString: err!)
  //        print("Error: \(errorMessage)")
  //        return
  //      }
  //
  //      let data = String(cString: json!)
  //      print(" \(data)")
  //    }
  //  }
  //
  //  @objc func getRedditProfile() {
  //    DispatchQueue.global(qos: .default).async {
  //      var json: UnsafeMutablePointer<CChar>?
  //      var proof: UnsafeMutablePointer<CChar>?
  //      var err: UnsafeMutablePointer<CChar>?
  //
  //      let status = opacity_core.get_reddit_account(&json, &proof, &err)
  //      if status != opacity_core.OPACITY_OK {
  //        let errorMessage = String(cString: err!)
  //        print("Error: \(errorMessage)")
  //        return
  //      }
  //
  //      let data = String(cString: json!)
  //      print(" \(data)")
  //    }
  //  }
  //
  //  @objc func getZabkaProfile() {
  //    DispatchQueue.global(qos: .default).async {
  //      var json: UnsafeMutablePointer<CChar>?
  //      var proof: UnsafeMutablePointer<CChar>?
  //      var err: UnsafeMutablePointer<CChar>?
  //
  //      let status = opacity_core.get_zabka_account(&json, &proof, &err)
  //      if status != opacity_core.OPACITY_OK {
  //        let errorMessage = String(cString: err!)
  //        print("Error: \(errorMessage)")
  //        return
  //      }
  //
  //      let data = String(cString: json!)
  //      print(" \(data)")
  //    }
  //  }
}
