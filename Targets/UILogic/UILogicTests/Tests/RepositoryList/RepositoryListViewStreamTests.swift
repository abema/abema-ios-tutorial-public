import XCTest
import RxSwift
import RxTest
import TestExtension
import UILogic
import UseCaseInterface

final class RepositoryListViewStreamTests: XCTestCase {

    func test_reloadData() {
        let mockRepository = RepositoryListUseCaseModel.Repository.mock()

        let dependency = Dependency()
        dependency.useCase.showRepositoryListHandler = {
            .just([mockRepository])
        }
        dependency.useCase.reloadRepositoryListHandler = {
            .just([mockRepository, mockRepository])
        }
        let testTarget = dependency.testTarget

        let reloadData = WatchStack(testTarget.output.reloadData)

        // 初期状態
        XCTAssertEqual(reloadData.count, 0)

        // viewWillAppearの後
        testTarget.input.viewWillAppear(())
        XCTAssertEqual(reloadData.count, 1)

        // リフレッシュ後
        testTarget.input.refreshControlValueChanged(())
        XCTAssertEqual(reloadData.count, 2)
    }

    func test_isRefreshControlRefreshing() {
        let mockRepository = RepositoryListUseCaseModel.Repository.mock()

        let dependency = Dependency()
        dependency.useCase.showRepositoryListHandler = {
            .just([mockRepository])
        }
        dependency.useCase.reloadRepositoryListHandler = {
            .just([mockRepository, mockRepository])
        }
        let testTarget = dependency.testTarget

        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)

        // 初期状態
        XCTAssertEqual(isRefreshControlRefreshing.events, [.next(false)])

        // viewWillAppearの後
        testTarget.input.viewWillAppear(())
        XCTAssertEqual(isRefreshControlRefreshing.events, [.next(false), .next(true), .next(false)])

        // リフレッシュ後
        testTarget.input.refreshControlValueChanged(())
        XCTAssertEqual(isRefreshControlRefreshing.events, [.next(false), .next(true), .next(false), .next(true), .next(false)])
    }

    func test_titles() {
        let owner = RepositoryListUseCaseModel.User.mock(login: "owner")
        let repository = RepositoryListUseCaseModel.Repository.mock(name: "name", owner: owner)

        let dependency = Dependency()
        dependency.useCase.showRepositoryListHandler = {
            .just([repository])
        }
        dependency.useCase.reloadRepositoryListHandler = {
            .just([repository, repository])
        }

        let testTarget = dependency.testTarget

        let titles = WatchStack(testTarget.output.titles)

        // 初期状態
        XCTAssertEqual(titles.value, [])

        // viewWillAppearの後
        testTarget.input.viewWillAppear(())

        XCTAssertEqual(titles.value, ["owner / name"])

        // リフレッシュ後
        testTarget.input.refreshControlValueChanged(())
        XCTAssertEqual(titles.value, ["owner / name", "owner / name"])
    }
}

extension RepositoryListViewStreamTests {
    struct Dependency {
        let testTarget: RepositoryListViewStream

        let useCase: RepositoryListUseCaseTypeMock

        init() {
            useCase = RepositoryListUseCaseTypeMock()
            testTarget = RepositoryListViewStream(repositoryListUseCase: useCase)

            useCase.showRepositoryListHandler = { Single.just([.mock()]) }
            useCase.reloadRepositoryListHandler = { Single.just([.mock()]) }
        }
    }
}
