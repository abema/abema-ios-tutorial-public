import XCTest
import RxSwift
import RxTest

@testable import AbemaTutorial

final class RepositoryListViewStreamTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testViewDidAppear() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction

        // 初期状態

        XCTAssertFalse(repositoryAction.isLoadCalled)

        // viewDidAppearの後

        testTarget.input.viewDidAppear(())
        XCTAssertTrue(repositoryAction.isLoadCalled)
    }

    func testViewWillAppear() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // viewWillAppearの後

        testTarget.input.viewWillAppear(())

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])
    }

    func testRefreshControlValueChanged() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // リフレッシュ後

        testTarget.input.refreshControlValueChanged(())

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])
    }

    func testFetchErrorAlertDismissed() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // アラートを閉じた後

        testTarget.input.fetchErrorAlertDismissed(())

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])
    }

    func testFetchError() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // アラートを閉じた後

        testTarget.input.fetchErrorAlertDismissed(())

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // エラーが返ってきた後

        repositoryAction._fetchResult.accept(.error(APIError.internalServerError))

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [.next(true)])
    }

    func testDidSelectCell() {
        let testTarget = dependency.testTarget
        let repositoryStore = dependency.repositoryStore

        let repositories = WatchStack(testTarget.output.repositories)
        let presentBookmarkAlert = WatchStack(testTarget.output.presentBookmarkAlert)
        let presentUnbookmarkAlert = WatchStack(testTarget.output.presentUnbookmarkAlert)

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertTrue(presentBookmarkAlert.events.isEmpty)
        XCTAssertTrue(presentUnbookmarkAlert.events.isEmpty)

        // セルの選択後

        let repository = Repository.mock()
        repositoryStore._repositories.accept([repository])

        let indexPath = IndexPath(row: 0, section: 0)
        testTarget.input.didSelectCell(indexPath)

        XCTAssertEqual(repositories.value, [repository])
        XCTAssertEqual(presentBookmarkAlert.value?.0, indexPath)
        XCTAssertEqual(presentBookmarkAlert.value?.1, repository)
        XCTAssertEqual(presentBookmarkAlert.events.count, 1)
        XCTAssertTrue(presentUnbookmarkAlert.events.isEmpty)

        // お気に入り登録済みのセルの選択後

        repositoryStore._bookmarks.accept([repository])

        testTarget.input.didSelectCell(indexPath)

        XCTAssertEqual(repositories.value, [repository])
        XCTAssertEqual(presentBookmarkAlert.value?.0, indexPath)
        XCTAssertEqual(presentBookmarkAlert.value?.1, repository)
        XCTAssertEqual(presentBookmarkAlert.events.count, 1)
        XCTAssertEqual(presentUnbookmarkAlert.value?.0, indexPath)
        XCTAssertEqual(presentUnbookmarkAlert.value?.1, repository)
        XCTAssertEqual(presentUnbookmarkAlert.events.count, 1)
    }

    func testDidBookmarkRepository() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        // 初期状態

        XCTAssertNil(repositoryAction._updateBookmarksResult)

        // お気に入り登録後

        let repository1 = Repository.mock(id: 1)
        let repository2 = Repository.mock(id: 2)

        repositoryStore._bookmarks.accept([repository1])

        testTarget.input.didBookmarkRepository(repository1)
        XCTAssertNil(repositoryAction._updateBookmarksResult)

        testTarget.input.didBookmarkRepository(repository2)
        XCTAssertEqual(repositoryAction._updateBookmarksResult, [repository1, repository2])
    }

    func testDidUnbookmarkRepository() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        // 初期状態

        XCTAssertNil(repositoryAction._updateBookmarksResult)

        // お気に入り削除後

        let repository1 = Repository.mock(id: 1)
        let repository2 = Repository.mock(id: 2)

        repositoryStore._bookmarks.accept([repository1, repository2])

        testTarget.input.didUnbookmarkRepository(repository1)
        XCTAssertEqual(repositoryAction._updateBookmarksResult, [repository2])
    }
}

extension RepositoryListViewStreamTests {
    struct Dependency {
        let testTarget: RepositoryListViewStream

        let repositoryStore: MockRepositoryStore
        let repositoryAction: MockRepositoryAction

        init() {
            repositoryStore = MockRepositoryStore()
            repositoryAction = MockRepositoryAction()

            let flux = Flux(repositoryStore: repositoryStore,
                            repositoryAction: repositoryAction)

            testTarget = RepositoryListViewStream(flux: flux)
        }
    }
}
