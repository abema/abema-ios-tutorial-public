import Domain
import RxSwift
import UseCaseInterface

public final class RepositoryListUseCase: RepositoryListUseCaseType {

    private let repositoryRepository: RepositoryRepositoryType

    public init(repositoryRepository: RepositoryRepositoryType) {
        self.repositoryRepository = repositoryRepository
    }

    public func showRepositoryList() -> Single<[UseCaseModel.Repository]> {
        _fetchRepositories(limit: 20, offset: 0)
    }

    public func reloadRepositoryList() -> Single<[UseCaseModel.Repository]> {
        _fetchRepositories(limit: 20, offset: 0)
    }

    private func _fetchRepositories(limit: Int, offset: Int) -> Single<[UseCaseModel.Repository]> {
        repositoryRepository.fetchRepositories(limit: limit, offset: offset)
            .map { repositories -> [UseCaseModel.Repository] in
                if repositories.isEmpty {
                    return []
                }

                return repositories.map { repository in
                    let owner = repository.owner

                    return UseCaseModel.Repository(
                        id: repository.id,
                        name: repository.name,
                        description: repository.description,
                        owner: .init(id: owner.id, login: owner.login)
                    )
                }
            }
            .catchAndReturn([])
    }
}
