import RxSwift
import RxRelay

@testable import AbemaTutorial

final class MockRepositoryStore: RepositoryStoreType {
    var repositories: Property<[Repository]> {
        return Property(_repositories)
    }

    let _repositories = BehaviorRelay<[Repository]>(value: [])

    var bookmarks: Property<[Repository]> {
        return Property(_bookmarks)
    }

    let _bookmarks = BehaviorRelay<[Repository]>(value: [])
}
