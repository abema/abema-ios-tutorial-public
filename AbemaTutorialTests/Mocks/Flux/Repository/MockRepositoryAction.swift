import RxSwift
import RxRelay

@testable import AbemaTutorial

final class MockRepositoryAction: RepositoryActionType {
    private(set) var isLoadCalled: Bool = false

    func load() {
        isLoadCalled = true
    }

    let _fetchResult = PublishRelay<Event<Void>>()

    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void> {
        return _fetchResult.dematerialize()
    }

    private(set) var _updateBookmarksResult: [Repository]?

    func updateBookmarks(bookmarks: [Repository]) {
        _updateBookmarksResult = bookmarks
    }
}
