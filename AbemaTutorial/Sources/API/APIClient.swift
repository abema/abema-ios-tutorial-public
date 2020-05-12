import Foundation
import RxSwift

protocol APIClientType {
    func fetchRepositories(limit: Int, offset: Int) -> Observable<[Repository]>
}

final class APIClient: APIClientType {
    static let shared = APIClient()

    func fetchRepositories(limit: Int, offset: Int) -> Observable<[Repository]> {
        return stubFetchRepositories(limit: limit, offset: offset)
    }
}

extension APIClient {
    /// スタブ実装. 課題遂行のために変更してはいけません.
    private func stubFetchRepositories(limit: Int, offset: Int) -> Observable<[Repository]> {
        let decoder = JSONDecoder()
        guard
            let url = Bundle.main.url(forResource: "repositories", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let repositories = try? decoder.decode([Repository].self, from: data)
        else { fatalError("Stub data could not be found or malformed") }

        return Observable
            .just(())
            .delay(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .default))
            .map { _ in Array(repositories[offset ..< offset + limit]) }
            .flatMap { repositories -> Observable<[Repository]> in
                Int.random(in: 0 ..< 10) > 0 ? .just(repositories) : .error(APIError.internalServerError)
            }
    }
}
