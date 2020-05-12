import Action
import RxRelay
import RxSwift
import Unio

protocol RepositoryListViewStreamType: AnyObject {
    var input: InputWrapper<RepositoryListViewStream.Input> { get }
    var output: OutputWrapper<RepositoryListViewStream.Output> { get }
}

final class RepositoryListViewStream: UnioStream<RepositoryListViewStream>, RepositoryListViewStreamType {

    convenience init(flux: Flux = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(flux: flux))
    }
}

extension RepositoryListViewStream {
    struct Input: InputType {
        let viewWillAppear = PublishRelay<Void>()
        let refreshControlValueChanged = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let repositories: BehaviorRelay<[Repository]>
        let reloadData: PublishRelay<Void>
        let isRefreshControlRefreshing: BehaviorRelay<Bool>
    }

    struct State: StateType {
        let repositories = BehaviorRelay<[Repository]>(value: [])
        let isRefreshControlRefreshing = BehaviorRelay<Bool>(value: false)
    }

    struct Extra: ExtraType {
        let flux: Flux

        let fetchRepositoriesAction: Action<(limit: Int, offset: Int), Void>
    }
}

extension RepositoryListViewStream {
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let state = dependency.state
        let extra = dependency.extra

        let flux = extra.flux
        let fetchRepositoriesAction = extra.fetchRepositoriesAction

        let viewWillAppear = dependency.inputObservables.viewWillAppear
        let refreshControlValueChanged = dependency.inputObservables.refreshControlValueChanged

        let fetchRepositories = Observable
            .merge(viewWillAppear,
                   refreshControlValueChanged)

        fetchRepositories
            .map { (limit: Const.count, offset: 0) }
            .bind(to: fetchRepositoriesAction.inputs)
            .disposed(by: disposeBag)

        flux.repositoryStore.repositories.asObservable()
            .bind(to: state.repositories)
            .disposed(by: disposeBag)

        fetchRepositoriesAction.errors
            .subscribe(onNext: { error in print("API Error: \(error)") })
            .disposed(by: disposeBag)

        let reloadData = PublishRelay<Void>()

        state.repositories
            .map(void)
            .bind(to: reloadData)
            .disposed(by: disposeBag)

        return Output(repositories: state.repositories,
                      reloadData: reloadData,
                      isRefreshControlRefreshing: state.isRefreshControlRefreshing)
    }
}

extension RepositoryListViewStream.Extra {
    init(flux: Flux) {
        self.flux = flux

        let repositoryAction = flux.repositoryAction

        self.fetchRepositoriesAction = Action { limit, offset in
            repositoryAction.fetchRepositories(limit: limit, offset: offset)
        }
    }
}

extension RepositoryListViewStream {
    enum Const {
        static let count: Int = 20
    }
}
