import XCTest

@testable import AbemaTutorial

class BookmarkListViewStreamTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testViewStream() {
        let testTarget = dependency.testTarget
        let repositoryStore = dependency.repositoryStore

        let bookmarks = WatchStack(testTarget.output.bookmarks)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true })

        // 初期データを投入
        let currentBookmark1 = Repository.mock(id: 1)
        repositoryStore._bookmarks.accept([currentBookmark1])

        // 初期状態
        XCTAssertEqual(bookmarks.value, [currentBookmark1])
        XCTAssertEqual(reloadData.events, [.next(true)])

        let currentBookmark2 = Repository.mock(id: 2)
        repositoryStore._bookmarks.accept([currentBookmark1, currentBookmark2])

        // お気に入り登録された後
        XCTAssertEqual(bookmarks.value, [currentBookmark1, currentBookmark2])
        XCTAssertEqual(reloadData.events, [.next(true), .next(true)])
    }
}

extension BookmarkListViewStreamTests {
    struct Dependency {
        let testTarget: BookmarkListViewStream

        let repositoryStore: MockRepositoryStore
        let repositoryAction: MockRepositoryAction

        init() {
            repositoryStore = MockRepositoryStore()
            repositoryAction = MockRepositoryAction()

            let flux =  Flux(repositoryStore: repositoryStore,
                             repositoryAction: repositoryAction)

            testTarget = BookmarkListViewStream(flux: flux)
        }
    }
}
