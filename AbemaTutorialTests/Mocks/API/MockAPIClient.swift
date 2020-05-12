import RxSwift
import RxRelay

@testable import AbemaTutorial

final class MockAPIClient: APIClientType {
    let _fetchRepositories = PublishRelay<Event<[Repository]>>()

    func fetchRepositories(limit: Int, offset: Int) -> Observable<[Repository]> {
        return _fetchRepositories.dematerialize()
    }
}
