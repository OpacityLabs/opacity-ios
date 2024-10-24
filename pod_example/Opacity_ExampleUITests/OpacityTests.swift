import XCTest

final class OpacityTests: XCTestCase {
  override class var runsForEachTargetApplicationUIConfiguration: Bool {
    false
  }

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testClosingTheBrowserShouldSetStatusToFailed() throws {
      let app = XCUIApplication()
      app.launch()
      app/*@START_MENU_TOKEN@*/.staticTexts["Uber get rider profile"]/*[[".buttons[\"Uber get rider profile\"].staticTexts[\"Uber get rider profile\"]",".staticTexts[\"Uber get rider profile\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      app.navigationBars["ModalWebView"].buttons["Close"].tap()
      
      let failedStaticText = app.staticTexts["Failed"]
                  
      XCTAssertTrue(failedStaticText.exists, "The status label should indicate 'Failed'")
  }
    
    func testGetUberRiderProfileShouldSucceed() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
