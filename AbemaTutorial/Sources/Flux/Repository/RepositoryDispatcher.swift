struct RepositoryDispatcher {
    static let shared = RepositoryDispatcher()

    let updateRepositories = DispatchRelay<[Repository]>()
}
