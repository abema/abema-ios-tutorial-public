import XCTest
import RxSwift
import RxTest

@testable import AbemaTutorial

final class RepositoryListCellStreamTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testTitleText() {
        let testTarget = dependency.testTarget

        let owner = User(id: 123, login: "owner")
        let repository = Repository(id: 123, name: "name", description: "description", owner: owner)

        let titleText = WatchStack(testTarget.output.titleText)

        testTarget.input.repository(repository)

        XCTAssertEqual(titleText.value, "owner / name")
    }
}

extension RepositoryListCellStreamTests {
    struct Dependency {
        let testTarget: RepositoryListCellStream

        init() {
            testTarget = RepositoryListCellStream()
        }
    }
}
