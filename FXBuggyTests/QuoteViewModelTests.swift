import XCTest
@testable import FXBuggy

final class QuoteViewModelTests: XCTestCase {

    func test_Convert_100_USD_to_SGD_ShouldBe_134() {
        let vm = QuoteViewModel(service: RateService(), toCode: "SGD")

        vm.amountText = "100"

        let exp = expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(vm.resultText.contains("134.00"), "should be 134.00 SGD")
    }
}
