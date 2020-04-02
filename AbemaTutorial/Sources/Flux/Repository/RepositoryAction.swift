import Foundation
import RxSwift

protocol RepositoryActionType {
    func load()
    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void>
    func updateBookmarks(bookmarks: [Repository])
}

final class RepositoryAction: RepositoryActionType {
    static let shared = RepositoryAction()

    private let apiClient: APIClientType
    private let userDefaults: UserDefaultsType
    private let dispatcher: RepositoryDispatcher

    init(apiClient: APIClientType = APIClient.shared,
         userDefaults: UserDefaultsType = UserDefaults.standard,
         dispatcher: RepositoryDispatcher = .shared) {
        self.apiClient = apiClient
        self.userDefaults = userDefaults
        self.dispatcher = dispatcher
    }

    func load() {
        if let bookmarks = try? userDefaults.get(key: .bookmarks, of: [Repository].self) {
            dispatcher.updateBookmarks.dispatch(bookmarks)
        }
    }

    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void> {
        return apiClient
            .fetchRepositories(limit: limit, offset: offset)
            .do(onNext: { [dispatcher] repositories in
                dispatcher.updateRepositories.dispatch(repositories)
            })
            .map(void)
    }

    func updateBookmarks(bookmarks: [Repository]) {
        userDefaults.set(key: .bookmarks, newValue: bookmarks)
        dispatcher.updateBookmarks.dispatch(bookmarks)
    }
}
