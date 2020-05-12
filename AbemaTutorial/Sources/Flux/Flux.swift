struct Flux {
    static let shared = Flux()

    let repositoryStore: RepositoryStoreType
    let repositoryAction: RepositoryActionType

    init(repositoryStore: RepositoryStoreType = RepositoryStore.shared,
         repositoryAction: RepositoryActionType = RepositoryAction.shared) {
        self.repositoryStore = repositoryStore
        self.repositoryAction = repositoryAction
    }
}
