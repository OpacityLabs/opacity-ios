import BackgroundTasks
import OpacityCoreSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  private let backgroundTaskIdentifier = "com.opacity.fetchGitHubProfile"

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    OpacitySwiftWrapper.getSecretValue()

    BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) {
      task in
      self.handleGitHubProfileFetch(task: task as! BGAppRefreshTask)
    }

    // Schedule the task
    scheduleGitHubProfileFetch()

    return true
  }

  private func handleGitHubProfileFetch(task: BGAppRefreshTask) {
    let startTime = Date()
    print("🚀 Background task started at \(startTime)")

    // Schedule the next refresh
    scheduleGitHubProfileFetch()

    task.expirationHandler = {
      print("⏰ Background task expired at \(Date())")
    }

    // Perform async work using Swift Concurrency
    Task {
      do {
        OpacitySwiftWrapper.getSecretValue()

        _ = try await OpacitySwiftWrapper
          .get(name: "github:profile", params: nil)
        let endTime = Date()
        print("✅ SUCCESS at \(endTime): GitHub profile fetched ")
        print("⏱️ Duration: \(endTime.timeIntervalSince(startTime)) seconds")
        task.setTaskCompleted(success: true)
      } catch {
        print(
          "❌ FAILURE at \(Date()): Failed to fetch GitHub profile - \(error.localizedDescription)")
        task.setTaskCompleted(success: false)
      }
    }
  }

  private func scheduleGitHubProfileFetch() {
    let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // 15 minutes from now

    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("❌ Could not schedule background task: \(error.localizedDescription)")
    }
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(
      name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(
    _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
  }
}
