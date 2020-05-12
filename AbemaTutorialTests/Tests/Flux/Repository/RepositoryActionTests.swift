import XCTest
import RxSwift
import RxTest

@testable import AbemaTutorial

final class RepositoryActionTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testFetchRepositories() {
        let testTarget = dependency.testTarget
        let apiClient = dependency.apiClient

        let mockRepository = Repository.mock()

        let fetchRepositories = WatchStack(
            testTarget
                .fetchRepositories(limit: 123, offset: 123)
                .map { true } // Voidだと比較できないのでBool化
        )

        // 初期状態
        XCTAssertEqual(fetchRepositories.events, [])

        // APIClientから結果返却後
        apiClient._fetchRepositories.accept(.next([mockRepository]))
        apiClient._fetchRepositories.accept(.completed)

        XCTAssertEqual(fetchRepositories.events, [.next(true), .completed])
    }
}

extension RepositoryActionTests {
    struct Dependency {
        let testTarget: RepositoryAction

        let apiClient: MockAPIClient
        let repositoryStore: MockRepositoryStore

        init() {
            apiClient = MockAPIClient()
            repositoryStore = MockRepositoryStore()

            testTarget = RepositoryAction(apiClient: apiClient)
        }
    }
}
