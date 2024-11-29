import CoreLocation
import OpacityCore
import UIKit

class MainViewController: UIViewController {

  let buttons = [
    ("uber get rider profile", #selector(getRiderProfile)),
    ("uber rider trip history", #selector(getUberRiderTripHistory)),
    ("zabka Profile", #selector(getZabkaProfile)),
    ("reddit account", #selector(getRedditProfile)),
    ("github profile", #selector(getGithubProfile)),
    ("run lua", #selector(runLua)),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let env = loadEnvFile(), let apiKey = env["OPACITY_API_KEY"] else {
      print("Error loading .env file or API key not found")
      return
    }

    do {
      try OpacitySwiftWrapper.initialize(apiKey: apiKey, dryRun: false, environment: .Test)
    } catch {
      let errorLabel = UILabel()
      errorLabel.text = "SDK is not initialized"
      errorLabel.textColor = .red
      errorLabel.frame = CGRect(x: 120, y: 50, width: 200, height: 50)
      view.addSubview(errorLabel)
    }

    for (index, buttonInfo) in buttons.enumerated() {
      let button = UIButton(type: .system)
      button.setTitle(buttonInfo.0, for: .normal)
      button.addTarget(self, action: buttonInfo.1, for: .touchUpInside)
      button.frame = CGRect(x: 100, y: 80 + (index * 30), width: 200, height: 50)
      view.addSubview(button)
    }
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

  @objc func getRiderProfile() async {
    do {
      let (json) = try await OpacitySwiftWrapper.getUberRiderProfile()
      print(json)
    } catch {
      print("Could not get uber rider profile: \(error)")
    }
  }

  @objc func getUberRiderTripHistory() async {
    do {
      let (json) = try await OpacitySwiftWrapper.getUberRiderTripHistory(cursor: "")
      print(json)
    } catch {
      print("Could not get uber rider profile: \(error)")
    }
  }

  @objc func getRedditProfile() async {
    do {
      let (json) = try await OpacitySwiftWrapper.getRedditAccount()
      print(json)
    } catch {
      print("Could not get reddit account: \(error)")
    }
  }

  @objc func getZabkaProfile() async {
    do {
      let (json) = try await OpacitySwiftWrapper.getZabkaAccount()
      print(json)
    } catch {
      print("Could not get zabka account: \(error)")
    }
  }

  @objc func getGithubProfile() async {
    do {
      let (json) = try await OpacitySwiftWrapper.getGithubProfile()
      print(json)
    } catch {
      print("Could not get github account: \(error)")
    }
  }

  @objc func runLua() {
    DispatchQueue.global(qos: .userInteractive).async {
      OpacitySwiftWrapper.runLua()
    }
  }
}
