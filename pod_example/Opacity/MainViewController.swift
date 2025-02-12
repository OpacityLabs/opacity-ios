import CoreLocation
import OpacityCore
import UIKit

class MainViewController: UIViewController {

  var buttons: [(String, () async throws -> Void)]!

  override func viewDidLoad() {
    super.viewDidLoad()
    buttons = [
      ("flow:uber_rider:profile", getRiderProfile),
      ("flow:gusto:profile_pay", gustoProfilePay),
      ("404 flow", run404Flow),
    ]
    view.backgroundColor = .black

    guard let env = loadEnvFile(), let apiKey = env["OPACITY_API_KEY"]
    else {
      print("Error loading .env file or API key not found")
      return
    }

    do {
      try OpacitySwiftWrapper.initialize(
        apiKey: apiKey, dryRun: false, environment: .Production,
        shouldShowErrorsInWebView: true)
    } catch {
      let errorLabel = UILabel()
      errorLabel.text =
        "⚠️ SDK is not initialized! Check server is started and API key"
      errorLabel.textColor = .red
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
      return
    }

    for (index, buttonInfo) in buttons.enumerated() {
      let button = UIButton(type: .system)
      button.setTitle(buttonInfo.0, for: .normal)
      button.tag = index
      button.addTarget(
        self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
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
          let key = keyValuePair[0].trimmingCharacters(
            in: .whitespaces)
          let value = keyValuePair[1].trimmingCharacters(
            in: .whitespaces)
          envVariables[key] = value
        }
      }

      return envVariables
    } catch {
      print("Error reading .env file: \(error.localizedDescription)")
      return nil
    }
  }

  func showGreenToast(message: String) {
    let toastLabel = UILabel()
    toastLabel.backgroundColor = UIColor.green.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    toastLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toastLabel)

    NSLayoutConstraint.activate([
      toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      toastLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
      toastLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
      toastLabel.heightAnchor.constraint(equalToConstant: 35),
    ])

    UIView.animate(
      withDuration: 4.0, delay: 0.1, options: .curveEaseOut,
      animations: {
        toastLabel.alpha = 0.0
      },
      completion: { _ in
        toastLabel.removeFromSuperview()
      })
  }

  func showRedToast(message: String) {
    let toastLabel = UILabel()
    toastLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    toastLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toastLabel)

    NSLayoutConstraint.activate([
      toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      toastLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
      toastLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
      toastLabel.heightAnchor.constraint(equalToConstant: 35),
    ])

    UIView.animate(
      withDuration: 4.0, delay: 0.1, options: .curveEaseOut,
      animations: {
        toastLabel.alpha = 0.0
      },
      completion: { _ in
        toastLabel.removeFromSuperview()
      })
  }

  @objc private func buttonTapped(_ sender: UIButton) {
    let action = buttons[sender.tag].1
    Task {
      do {
        try await action()
        showGreenToast(message: "Success")
      } catch {
        showRedToast(message: "Error: \(error.localizedDescription)")
      }
    }
  }

  func getRiderProfile() async throws {
    let (json) = try await OpacitySwiftWrapper.get(
      name: "flow:uber_rider:profile",
      params: nil
    )
    print("uber rider profile: \(json)")
  }

  func gustoProfilePay() async throws {
    let res = try await OpacitySwiftWrapper.get(
      name: "flow:gusto:profile_pay", params: nil)
    print(res)
  }

  func run404Flow() async throws {
    let res = try await OpacitySwiftWrapper.get(
      name: "404", params: nil)
    print(res)
  }

}
