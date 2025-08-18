import CoreLocation
import OpacityCore
import UIKit

class MainViewController: UIViewController {
  
  var buttons: [(String, () async throws -> Void)]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    buttons = [
      ("uber_rider:profile", getRiderProfile),
      ("test:open_browser_must_succeed", testFlowAlwaysResolves),
      ("404 flow", run404Flow),
      ("re-initialize SDK", reinitializeSdk),
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
        shouldShowErrorsInWebView: false)
    } catch {
      let errorLabel = UILabel()
      errorLabel.text =
      "🔺 SDK init error: \(error)"
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
        x: 100, y: 80 + (index * 40), width: 200, height: 50)
      view.addSubview(button)
    }
    
    let inputField = UITextField()
    inputField.borderStyle = .roundedRect
    inputField.placeholder = "Enter flow name"
    inputField.translatesAutoresizingMaskIntoConstraints = false
    // Disable autocapitalization and autocorrection
    inputField.autocapitalizationType = .none
    inputField.autocorrectionType = .no
    inputField.spellCheckingType = .no
    // Load the saved value if it exists
    inputField.text = UserDefaults.standard.string(forKey: "savedFlowName")
    // Add a target to save the value when editing ends
    inputField.addTarget(self, action: #selector(saveInputValue), for: .editingDidEnd)
    view.addSubview(inputField)
    
    let inputFieldParams = UITextField()
    inputFieldParams.borderStyle = .roundedRect
    inputFieldParams.placeholder = "Enter params as a json string"
    inputFieldParams.translatesAutoresizingMaskIntoConstraints = false
    // Disable autocapitalization and autocorrection
    inputFieldParams.autocapitalizationType = .none
    inputFieldParams.autocorrectionType = .no
    inputFieldParams.spellCheckingType = .no
    inputFieldParams.smartQuotesType = .no // we need this, otherwise the json is not valid, because the quotes are not normal quotes
    inputFieldParams.text = UserDefaults.standard.string(forKey: "savedParams")
    // Add a target to save the value when editing ends
    inputFieldParams.addTarget(self, action: #selector(saveInputParamsValue), for: .editingDidEnd)
    view.addSubview(inputFieldParams)
    
    let submitButton = UIButton(type: .system)
    submitButton.setTitle("Submit", for: .normal)
    submitButton.translatesAutoresizingMaskIntoConstraints = false
    submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    view.addSubview(submitButton)
    
    NSLayoutConstraint.activate([
      
      inputField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      inputField.topAnchor
        .constraint(equalTo: view.topAnchor, constant: 300),
      inputField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
      inputField.heightAnchor.constraint(equalToConstant: 40),
      
      inputFieldParams.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      inputFieldParams.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 30),
      inputFieldParams.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
      inputFieldParams.heightAnchor.constraint(equalToConstant: 40),
      
      submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      submitButton.topAnchor.constraint(equalTo: inputFieldParams.bottomAnchor, constant: 20),
      submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
      submitButton.heightAnchor.constraint(equalToConstant: 40),
    ])
  }
  
  @objc private func saveInputValue(_ sender: UITextField) {
    // Get the current input value
    if let value = sender.text, !value.isEmpty {
      // Save the value to UserDefaults
      UserDefaults.standard.set(value, forKey: "savedFlowName")
      UserDefaults.standard.synchronize()  // Ensure it's immediately written to disk
    }
  }
  
  @objc private func saveInputParamsValue(_ sender: UITextField) {
    // Get the current input value
    if let value = sender.text, !value.isEmpty {
      // Save the value to UserDefaults
      UserDefaults.standard.set(value, forKey: "savedParams")
      UserDefaults.standard.synchronize()  // Ensure it's immediately written to disk
    }
  }
  
  @objc private func submitButtonTapped() {
    guard let inputField = view.subviews.compactMap({ $0 as? UITextField }).first,
          let flowName = inputField.text, !flowName.isEmpty
    else {
      showRedToast(message: "Please enter a flow name")
      return
    }
    
    let textFields = view.subviews.compactMap { $0 as? UITextField }
    guard textFields.count > 1 else {
      showRedToast(message: "Not enough UITextFields")
      return
    }
    
    let jsonString = textFields[1].text ?? ""
    let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let parsed: [String: Any]?
    
    if trimmed.isEmpty {
      parsed = nil
    } else {
      guard let data = trimmed.data(using: .utf8) else {
        showRedToast(message: "String is not valid UTF-8")
        return
      }
      
      do {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let dict = json as? [String: Any] else {
          showRedToast(message: "JSON must be an object")
          return
        }
        parsed = dict
      } catch {
        showRedToast(message: "Invalid JSON")
        return
      }
    }
    
    // Save the flow name when submitting as well
    UserDefaults.standard.set(flowName, forKey: "savedFlowName")
    UserDefaults.standard.synchronize()
    
    Task {
      do {
        let res = try await OpacitySwiftWrapper.get(
          name: flowName.lowercased(),
          params: parsed
        )
        print(res)
        showGreenToast(message: "Success")
      } catch {
        showRedToast(message: "Unknown Error: \(error.localizedDescription)")
      }
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
    toastLabel.accessibilityIdentifier = "greenToast"
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
      toastLabel.removeFromSuperview()
    }
  }
  
  func showRedToast(message: String) {
    print(message)
    let toastLabel = UILabel()
    toastLabel.accessibilityIdentifier = "redToast"
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
      toastLabel.removeFromSuperview()
    }
    
  }
  
  @objc private func buttonTapped(_ sender: UIButton) {
    let action = buttons[sender.tag].1
    Task {
      do {
        try await action()
        showGreenToast(message: "Success")
      } catch let error as OpacityError {
        print("ERROR 🟥 \(error.code) - \(error.message)")
        showRedToast(message: "\(error.code) - \(error.message)")
      } catch {
        showRedToast(message: "Error: \(error.localizedDescription)")
      }
    }
  }
  
  func getRiderProfile() async throws {
    
    let json = try await OpacitySwiftWrapper.get(
      name: "uber_rider:profile",
      params: nil
    )
    print("uber rider profile: \(json)")
  }
  
  func testFlowAlwaysResolves() async throws {
    let _ = try await OpacitySwiftWrapper.get(
      name: "test:open_browser_must_succeed",
      params: nil
    )
    
  }
  
  func run404Flow() async throws {
    let res = try await OpacitySwiftWrapper.get(
      name: "404", params: nil)
    print(res)
  }
  
  func reinitializeSdk() {
    do {
      guard let env = loadEnvFile(), let apiKey = env["OPACITY_API_KEY"]
      else {
        print("Error loading .env file or API key not found")
        return
      }
      
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
    }
  }
  
}
