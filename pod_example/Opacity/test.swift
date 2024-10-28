import OpacityCore

func testOpacity() async {
    do {
        let (json, proof) = try await OpacitySwiftWrapper.getUberRiderProfile()
    } catch {
//    Intentionally left blank
    }
}
