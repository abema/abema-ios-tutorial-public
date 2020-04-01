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

    func testDetailTextLabel() {
        let testTarget = dependency.testTarget

        let owner = User(id: 1110, login: "koki")
        let repository = Repository(id: 1110, name: "hatena", description: "hatena???", owner: owner)

        let detailTextLabel = WatchStack(testTarget.output.detailTextLabel)

        testTarget.input.repository(repository)

        XCTAssertEqual(detailTextLabel.value, repository.description)
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
