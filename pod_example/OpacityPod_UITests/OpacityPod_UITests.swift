import XCTest

final class OpacityPod_UITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testFlowCanFailAndBeReopenedButAlsoReturnsError() throws {
    let app = XCUIApplication()
    app.launch()

    var button = app.buttons["uber_rider:profile"]
    button.tap()

    var browser = app.webViews.firstMatch
    XCTAssertTrue(browser.waitForExistence(timeout: 5), "In-app browser did not appear")
    var navigationBar = app.navigationBars.firstMatch

    var closeButton = navigationBar.buttons["Stop"]
    XCTAssertTrue(closeButton.exists, "Close button not found")
    closeButton.tap()

    button = app.buttons["uber_rider:profile"]
    button.tap()

    browser = app.webViews.firstMatch
    XCTAssertTrue(browser.waitForExistence(timeout: 5), "In-app browser did not appear")
    navigationBar = app.navigationBars.firstMatch
    XCTAssertTrue(navigationBar.exists, "Browser navigation bar not found")

    closeButton = navigationBar.buttons["Stop"]
    XCTAssertTrue(closeButton.exists, "Close button not found")
    closeButton.tap()

    let toast = app.staticTexts["redToast"]
    XCTAssertTrue(toast.waitForExistence(timeout: 10), "Red toast did not appear")
  }

  @MainActor
  func testFlowCompletes() {
    let app = XCUIApplication()
    app.launch()

    let button = app.buttons["test:open_browser_must_succeed"]
    button.tap()

    let toast = app.staticTexts["greenToast"]
    XCTAssertTrue(toast.waitForExistence(timeout: 10), "green toast did not appear")
  }

}
