import Extension
import RxRelay
import RxSwift
import UILogicInterface
import Unio
import UseCaseInterface

public final class RepositoryListViewStream: UnioStream<RepositoryListViewStream>, RepositoryListViewStreamType {

    public typealias Input = RepositoryListViewStreamInput
    public typealias Output = RepositoryListViewStreamOutput
    public typealias UseCaseModel = RepositoryListUseCaseModel

    public convenience init(
        repositoryListUseCase: RepositoryListUseCaseType
    ) {
        self.init(
            input: Input(),
            state: State(),
            extra: Extra(
                repositoryListUseCase: repositoryListUseCase
            )
        )
    }

    public struct State: StateType {
        let repositories = BehaviorRelay<[UseCaseModel.Repository]>(value: [])
        let isRefreshControlRefreshing = BehaviorRelay<Bool>(value: false)
        let titles = BehaviorRelay<[String]>(value: [])
    }

    public struct Extra: ExtraType {
        let repositoryListUseCase: RepositoryListUseCaseType
    }

    public static func bind(
        from dependency: Dependency<Input, State, Extra>,
        disposeBag: DisposeBag
    ) -> Output {
        let state = dependency.state
        let extra = dependency.extra
        let repositoryListUseCase = extra.repositoryListUseCase

        let viewWillAppear = dependency.inputObservables.viewWillAppear
        let refreshControlValueChanged = dependency.inputObservables.refreshControlValueChanged

        /// 画面表示時に取得したリポジトリ一覧
        let resultOfViewWillAppear: Observable<[UseCaseModel.Repository]> = viewWillAppear
            .flatMap { _ -> Single<[UseCaseModel.Repository]> in
                repositoryListUseCase.showRepositoryList()
            }
            .share()

        /// 再取得したリポジトリ一覧
        let resultOfRefresh: Observable<[UseCaseModel.Repository]> = refreshControlValueChanged
            .flatMap { _ -> Single<[UseCaseModel.Repository]> in
                repositoryListUseCase.reloadRepositoryList()
            }
            .share()

        Observable.merge(resultOfViewWillAppear, resultOfRefresh)
            .bind(to: state.repositories)
            .disposed(by: disposeBag)

        let reloadData = PublishRelay<Void>()

        state.repositories
            .map(void)
            .bind(to: reloadData)
            .disposed(by: disposeBag)

        state.repositories
            .map {
                $0.map { repository in
                    "\(repository.owner.login) / \(repository.name)"
                }
            }
            .bind(to: state.titles)
            .disposed(by: disposeBag)

        return Output(titles: state.titles,
                      reloadData: reloadData,
                      isRefreshControlRefreshing: state.isRefreshControlRefreshing)
    }
}
