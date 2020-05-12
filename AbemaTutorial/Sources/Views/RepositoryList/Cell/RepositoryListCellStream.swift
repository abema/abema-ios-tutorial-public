import Action
import RxRelay
import RxSwift
import Unio
import RxOptional

protocol RepositoryListCellStreamType: AnyObject {
    var input: InputWrapper<RepositoryListCellStream.Input> { get }
    var output: OutputWrapper<RepositoryListCellStream.Output> { get }
}

final class RepositoryListCellStream: UnioStream<RepositoryListCellStream>, RepositoryListCellStreamType {
    convenience init() {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra())
    }
}

extension RepositoryListCellStream {
    struct Input: InputType {
        let repository = PublishRelay<Repository?>()
        let prepareForReuse = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let titleText: BehaviorRelay<String>
    }

    struct State: StateType {
        let titleText = BehaviorRelay<String>(value: "")
    }

    struct Extra: ExtraType {}

}

extension RepositoryListCellStream {
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let state = dependency.state

        let repository = Observable
            .merge(dependency.inputObservables.repository,
                   dependency.inputObservables.prepareForReuse.map { nil })
            .filterNil()

        repository
            .map { "\($0.owner.login) / \($0.name)" }
            .bind(to: state.titleText)
            .disposed(by: disposeBag)

        return Output(titleText: state.titleText)
    }
}
