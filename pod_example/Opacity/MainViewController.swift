import CoreLocation
import OpacityCore
import UIKit

class MainViewController: UIViewController {

  let buttons = [
    ("uber get rider profile", #selector(getRiderProfileTapped)),
//    ("zabka Profile", #selector(getZabkaProfileButtonTapped)),
//    ("reddit account", #selector(getRedditProfileTapped)),
//    ("github profile", #selector(getGithubProfileButtonTapped)),
//    ("instagram profile", #selector(getInstagramProfileButtonTapped)),
    ("run lua", #selector(runLuaTapped)),
    ("run lua with params", #selector(runLuaWithParamsTapped)),
    ("run lua gusto", #selector(runLuaGustoTapped)),
    ("run lua with 404 flow", #selector(runLuaUndefinedTapped)),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    guard let env = loadEnvFile(), let apiKey = env["OPACITY_API_KEY"]
    else {
      print("Error loading .env file or API key not found")
      return
    }

    do {
      try OpacitySwiftWrapper.initialize(
        apiKey: apiKey, dryRun: false, environment: .Local)
    } catch {
      let errorLabel = UILabel()
      errorLabel.text =
        "⚠️ SDK is not initialized! Check server is started and API key"
      errorLabel.textColor = .red
      // errorLabel.frame = CGRect(x: 120, y: 50, width: .infinity, height: 50)
      errorLabel.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(errorLabel)
      NSLayoutConstraint.activate([
        errorLabel.centerXAnchor.constraint(
          equalTo: view.centerXAnchor),
        errorLabel.topAnchor.constraint(
          equalTo: view.topAnchor, constant: 50),
        errorLabel.widthAnchor.constraint(
          equalTo: view.widthAnchor, constant: -20),
      ])
      errorLabel.numberOfLines = 0
      errorLabel.lineBreakMode = .byWordWrapping
      view.addSubview(errorLabel)
    }

    for (index, buttonInfo) in buttons.enumerated() {
      let button = UIButton(type: .system)
      button.setTitle(buttonInfo.0, for: .normal)
      button.addTarget(self, action: buttonInfo.1, for: .touchUpInside)
      button.frame = CGRect(
        x: 100, y: 80 + (index * 30), width: 200, height: 50)
      view.addSubview(button)
    }
  }

  func loadEnvFile() -> [String: String]? {
    guard let filePath = Bundle.main.path(forResource: ".env", ofType: nil)
    else {
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

  @objc func getRiderProfileTapped() {
    Task {
      await getRiderProfile()
    }
  }

  func getRiderProfile() async {
    do {
      let (json) = try await OpacitySwiftWrapper.get(
        name: "flow:uber_rider:profile",
        params: nil
      )
      print("uber rider profile: \(json)")
    } catch {
      print("Could not get uber rider profile: \(error)")
    }
  }
//
//  @objc func getRedditProfileTapped() {
//    Task {
//      await getRedditProfile()
//    }
//  }
//
//  func getRedditProfile() async {
//    do {
//      let (json) = try await OpacitySwiftWrapper.getRedditAccount()
//      print(json)
//    } catch {
//      print("Could not get reddit account: \(error)")
//    }
//  }
//
//  @objc func getZabkaProfileButtonTapped() {
//    Task {
//      await getZabkaProfile()
//    }
//  }
//
//  func getZabkaProfile() async {
//    do {
//      let (json) = try await OpacitySwiftWrapper.getZabkaAccount()
//      print(json)
//    } catch {
//      print("Could not get zabka account: \(error)")
//    }
//  }
//
//  @objc func getGithubProfileButtonTapped() {
//    Task {
//      await getGithubProfile()
//    }
//  }
//
//  func getGithubProfile() async {
//    do {
//      let (json) = try await OpacitySwiftWrapper.getGithubProfile()
//      print(json)
//    } catch {
//      print("Could not get github account: \(error)")
//    }
//  }

  @objc func runLuaGustoTapped() {
    Task {
      await runLuaGusto()
    }
  }

  func runLuaGusto() async {
    do {
      let (json) = try await OpacitySwiftWrapper.get(
        name: "flow:gusto:my_pay", params: nil)
      print(json)
    } catch {
      print("Could not run lua: \(error)")
    }
  }

  @objc func runLuaTapped() {
    Task {
      await runLua()
    }
  }

  func runLua() async {
    do {
      let (json) = try await OpacitySwiftWrapper.get(

        name: "compiled", params: nil)
      print(json)
    } catch {
      print("Could not run lua: \(error)")
    }
  }

  @objc func runLuaWithParamsTapped() {
    Task {
      await runLuaWithParams()
    }
  }

  func runLuaWithParams() async {
    do {
      let jsonParams = ["param": "value"]

      let (json) = try await OpacitySwiftWrapper.get(
        name: "test_with_params", params: jsonParams)
      print(json)
    } catch {
      print("Could not run lua: \(error)")
    }
  }
//
//  @objc func getInstagramProfileButtonTapped() {
//    Task {
//      await getInstagramProfile()
//    }
//  }
//
//  func getInstagramProfile() async {
//    do {
//      let (json) = try await OpacitySwiftWrapper.getInstagramProfile()
//      print(json)
//    } catch {
//      print("Could not get instagram account: \(error)")
//    }
//  }

  @objc func runLuaUndefinedTapped() {
    Task {
      await runLuaUndefined()
    }
  }

  @MainActor
  func runLuaUndefined() async {
    do {
      let res = try await OpacitySwiftWrapper.get(
        name: "undefined", params: nil)
      print(res)
    } catch {
      print("Could not run lua: \(error)")
    }
  }

}
