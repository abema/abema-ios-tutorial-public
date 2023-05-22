import RxSwift

/// @mockable
public protocol RepositoryListUseCaseType: AnyObject {
    typealias UseCaseModel = RepositoryListUseCaseModel

    /// リポジトリ一覧を取得する
    func showRepositoryList() -> Single<[UseCaseModel.Repository]>

    /// リポジトリ一覧を再取得する
    func reloadRepositoryList() -> Single<[UseCaseModel.Repository]>
}

// MARK: UseCaseModels

public enum RepositoryListUseCaseModel {
    public struct Repository: Equatable {
        public let id: Int64
        public let name: String
        public let description: String
        public let owner: User

        public init(
            id: Int64,
            name: String,
            description: String,
            owner: User
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.owner = owner
        }
    }

    public struct User: Equatable {
        public let id: Int64
        public let login: String

        public init(id: Int64, login: String) {
            self.id = id
            self.login = login
        }
    }
}

public extension RepositoryListUseCaseModel.Repository {

    static func mock(
        id: Int64 = 123,
        name: String = "mock-repo",
        description: String = "mock repository",
        owner: RepositoryListUseCaseModel.User = .mock()
    ) -> RepositoryListUseCaseModel.Repository {
        .init(id: id, name: name, description: description, owner: owner)
    }
}

public extension RepositoryListUseCaseModel.User {

    static func mock(
        id: Int64 = 123,
        login: String = "mockowner"
    ) -> RepositoryListUseCaseModel.User {
        .init(id: id, login: login)
    }
}
