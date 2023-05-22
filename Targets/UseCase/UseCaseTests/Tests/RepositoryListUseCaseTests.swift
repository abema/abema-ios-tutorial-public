import Domain
import XCTest
import RxSwift
import RxTest
import UseCase
import UseCaseInterface
import TestExtension

final class RepositoryListUseCaseTests: XCTestCase {

    func testShowRepositoryList() {
        let owner: User = .mock(id: 421, login: "mockowner")
        let repository: Repository = .mock(
            id: 421,
            name: "mock-repo",
            description: "mock repository",
            owner: owner
        )

        let dependency = Dependency(repositoryListResult: [repository])
        let testTarget = dependency.testTarget

        let result = WatchStack(
            testTarget
                .showRepositoryList()
                .asObservable()
        )

        XCTAssertEqual(dependency.repositoryRepository.fetchRepositoriesCallCount, 1)
        XCTAssertEqual(result.value?.count, 1)
        XCTAssertEqual(result.value?.first?.id, repository.id)
        XCTAssertEqual(result.value?.first?.name, repository.name)
        XCTAssertEqual(result.value?.first?.description, repository.description)
        XCTAssertEqual(result.value?.first?.owner.id, repository.owner.id)
        XCTAssertEqual(result.value?.first?.owner.login, repository.owner.login)
    }

    func testFailToShowRepositoryList() {
        // リポジトリ一覧の取得に失敗する場合
        let dependency = Dependency()
        dependency.repositoryRepository.fetchRepositoriesHandler = { _, _ in
            Single.error(RepositoryRepositoryError.fetchError)
        }

        let result = WatchStack(
            dependency.testTarget
                .reloadRepositoryList()
                .asObservable()
        )

        XCTAssertEqual(dependency.repositoryRepository.fetchRepositoriesCallCount, 1)
        XCTAssertEqual(result.value, [])
    }

    func testReloadRepositoryList() {
        let owner: User = .mock(id: 421, login: "mockowner")
        let repository: Repository = .mock(
            id: 421,
            name: "mock-repo",
            description: "mock repository",
            owner: owner
        )

        let dependency = Dependency(repositoryListResult: [repository])
        let testTarget = dependency.testTarget

        let result = WatchStack(
            testTarget
                .reloadRepositoryList()
                .asObservable()
        )

        XCTAssertEqual(dependency.repositoryRepository.fetchRepositoriesCallCount, 1)
        XCTAssertEqual(result.value?.count, 1)
        XCTAssertEqual(result.value?.first?.id, repository.id)
        XCTAssertEqual(result.value?.first?.name, repository.name)
        XCTAssertEqual(result.value?.first?.description, repository.description)
        XCTAssertEqual(result.value?.first?.owner.id, repository.owner.id)
        XCTAssertEqual(result.value?.first?.owner.login, repository.owner.login)
    }

    func testFailToReloadRepositoryList() {
        // リポジトリ一覧の取得に失敗する場合
        let dependency = Dependency()
        dependency.repositoryRepository.fetchRepositoriesHandler = { _, _ in
            Single.error(RepositoryRepositoryError.fetchError)
        }

        let result = WatchStack(
            dependency.testTarget
                .reloadRepositoryList()
                .asObservable()
        )

        XCTAssertEqual(dependency.repositoryRepository.fetchRepositoriesCallCount, 1)
        XCTAssertEqual(result.value, [])
    }
}

extension RepositoryListUseCaseTests {
    struct Dependency {
        let testTarget: UseCase.RepositoryListUseCase

        let repositoryRepository = RepositoryRepositoryTypeMock()

        var repositoryListResult: [Repository]

        init(
            repositoryListResult: [Repository] = [.mock()]
        ) {
            self.repositoryListResult = repositoryListResult

            testTarget = RepositoryListUseCase(repositoryRepository: repositoryRepository)

            repositoryRepository.fetchRepositoriesHandler = { _, _ in
                Single.just(repositoryListResult)
            }
        }
    }
}
