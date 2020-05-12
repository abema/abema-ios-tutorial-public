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

    func testViewWillAppear() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)

        // viewWillAppearの後

        testTarget.input.viewWillAppear(())

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)

        // リフレッシュ後

        testTarget.input.refreshControlValueChanged(())

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true), .next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
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
