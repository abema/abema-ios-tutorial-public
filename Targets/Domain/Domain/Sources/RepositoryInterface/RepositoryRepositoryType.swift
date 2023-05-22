import RxSwift

/// @mockable
public protocol RepositoryRepositoryType: AnyObject {
    func fetchRepositories(limit: Int, offset: Int) -> Single<[Repository]>
}

public enum RepositoryRepositoryError: Error {
    case fetchError
}
