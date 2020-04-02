import Foundation
import RxSwift
import RxRelay

protocol RepositoryStoreType {
    var repositories: Property<[Repository]> { get }
    var bookmarks: Property<[Repository]> { get }
}

final class RepositoryStore: RepositoryStoreType {
    static let shared = RepositoryStore()

    @BehaviorWrapper(value: [])
    private(set) var repositories: Property<[Repository]>

    @BehaviorWrapper(value: [])
    private(set) var bookmarks: Property<[Repository]>

    private let disposeBag = DisposeBag()

    init(dispatcher: RepositoryDispatcher = .shared) {

        dispatcher.updateRepositories
            .bind(to: _repositories)
            .disposed(by: disposeBag)

        dispatcher.updateBookmarks
            .bind(to: _bookmarks)
            .disposed(by: disposeBag)
    }
}
