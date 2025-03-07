import XCTest

final class OpacityPod_UITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  //    override func tearDownWithError() throws {
  //    }

  @MainActor
  func testInAppBrowserOpens() throws {
    let app = XCUIApplication()
    app.launch()
    let button = app.buttons["flow:uber_rider:profile"]
    button.tap()
    // Wait for the browser to appear
    let browser = app.webViews.firstMatch
    XCTAssertTrue(browser.waitForExistence(timeout: 5), "In-app browser did not appear")

    // Additional verification that it's a browser (optional)
    // You might check for typical browser elements like address bar or navigation buttons
    let navigationBar = app.navigationBars.firstMatch
    XCTAssertTrue(navigationBar.exists, "Browser navigation bar not found")
  }
}
