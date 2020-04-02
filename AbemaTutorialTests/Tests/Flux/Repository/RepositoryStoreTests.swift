import RxSwift
import RxTest
import XCTest

@testable import AbemaTutorial

final class RepositoryStoreTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testRepositories() {
        let testTarget = dependency.testTarget
        let dispatcher = dependency.dispatcher

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.repositories.asObservable())

        // 初期状態
        XCTAssertEqual(repositories.events, [.next([])])

        dispatcher.updateRepositories.dispatch([mockRepository])

        XCTAssertEqual(repositories.events, [.next([]), .next([mockRepository])])
    }

    func testBookmarks() {
        let mockRepository = Repository.mock()

        let testTarget = dependency.testTarget
        let dispatcher = dependency.dispatcher

        let bookmarks = WatchStack(testTarget.bookmarks.asObservable())

        // 初期状態
        XCTAssertEqual(bookmarks.events, [.next([])])

        dispatcher.updateBookmarks.dispatch([mockRepository])

        XCTAssertEqual(bookmarks.events, [.next([]),
                                          .next([mockRepository])])
    }
}

extension RepositoryStoreTests {
    struct Dependency {
        let testTarget: RepositoryStore

        let dispatcher: RepositoryDispatcher

        init(userDefaults: UserDefaultsType = MockUserDefaults()) {
            self.dispatcher = RepositoryDispatcher()

            self.testTarget = RepositoryStore(dispatcher: dispatcher)
        }
    }
}
