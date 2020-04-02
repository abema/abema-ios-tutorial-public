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

    func testLoad() {
        let testTarget = dependency.testTarget
        let userDefaults = dependency.userDefaults
        let repositoryDispatcher = dependency.repositoryDispatcher

        let mockRepositories = [Repository.mock()]

        let updateBookmarks = WatchStack(repositoryDispatcher.updateBookmarks)

        // 初期状態
        XCTAssertEqual(updateBookmarks.events, [])
        XCTAssertThrowsError(try userDefaults.get(key: .bookmarks, of: [Repository].self))

        // お気に入り登録
        userDefaults.set(key: .bookmarks, newValue: mockRepositories)
        testTarget.load()

        XCTAssertEqual(updateBookmarks.events, [.next(mockRepositories)])
        XCTAssertNoThrow(try userDefaults.get(key: .bookmarks, of: [Repository].self))
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

    func testUpdateBookmarks() {
        let testTarget = dependency.testTarget
        let userDefaults = dependency.userDefaults
        let repositoryDispatcher = dependency.repositoryDispatcher

        let mockRepositories = [Repository.mock()]

        let updateBookmarks = WatchStack(repositoryDispatcher.updateBookmarks)

        // 初期状態
        XCTAssertEqual(updateBookmarks.events, [])
        XCTAssertThrowsError(try userDefaults.get(key: .bookmarks, of: [Repository].self))

        // お気に入り登録
        testTarget.updateBookmarks(bookmarks: mockRepositories)

        XCTAssertEqual(updateBookmarks.events, [.next(mockRepositories)])
        XCTAssertNoThrow(try userDefaults.get(key: .bookmarks, of: [Repository].self))
    }
}

extension RepositoryActionTests {
    struct Dependency {
        let testTarget: RepositoryAction

        let apiClient: MockAPIClient
        let userDefaults: MockUserDefaults
        let repositoryDispatcher: RepositoryDispatcher

        init() {
            apiClient = MockAPIClient()
            userDefaults = MockUserDefaults()
            repositoryDispatcher = RepositoryDispatcher()

            testTarget = RepositoryAction(apiClient: apiClient,
                                          userDefaults: userDefaults,
                                          dispatcher: repositoryDispatcher)
        }
    }
}
