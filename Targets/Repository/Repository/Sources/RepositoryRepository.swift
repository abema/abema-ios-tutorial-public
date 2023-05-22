import Foundation
import RxSwift
import Domain

public final class RepositoryRepository: RepositoryRepositoryType {

    public init() {}

    public func fetchRepositories(limit: Int, offset: Int) -> Single<[Repository]> {
        return stubFetchRepositories(limit: limit, offset: offset)
    }
}

extension RepositoryRepository {
    /// スタブ実装. 課題遂行のために変更してはいけません.
    private func stubFetchRepositories(limit: Int, offset: Int) -> Single<[Repository]> {
        let decoder = JSONDecoder()
        // repositories.jsonは、Repositoryに置きたいが、static frameworkであるために、置くことができないので、AbemaTutorialに定義する
        guard
            let url = Bundle.main.url(forResource: "repositories", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let repositories = try? decoder.decode([Repository].self, from: data)
        else { fatalError("Stub data could not be found or malformed") }

        return Single
            .just(())
            .delay(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .default))
            .map { _ in Array(repositories[offset ..< offset + limit]) }
            .flatMap { repositories -> Single<[Repository]> in
                Int.random(in: 0 ..< 10) > 0 ? .just(repositories) : .error(RepositoryRepositoryError.fetchError)
            }
    }
}
