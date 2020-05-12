import RxSwift

protocol RepositoryActionType {
    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void>
}

final class RepositoryAction: RepositoryActionType {
    static let shared = RepositoryAction()

    private let apiClient: APIClientType
    private let dispatcher: RepositoryDispatcher

    init(apiClient: APIClientType = APIClient.shared,
         dispatcher: RepositoryDispatcher = .shared) {
        self.apiClient = apiClient
        self.dispatcher = dispatcher
    }

    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void> {
        return apiClient
            .fetchRepositories(limit: limit, offset: offset)
            .do(onNext: { [dispatcher] repositories in
                dispatcher.updateRepositories.dispatch(repositories)
            })
            .map(void)
    }
}
