import Action
import RxRelay
import RxSwift
import Unio

protocol BookmarkListViewStreamType: AnyObject {
    var input: InputWrapper<BookmarkListViewStream.Input> { get }
    var output: OutputWrapper<BookmarkListViewStream.Output> { get }
}

final class BookmarkListViewStream: UnioStream<BookmarkListViewStream>, BookmarkListViewStreamType {

    convenience init(flux: Flux = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(flux: flux))
    }
}

extension BookmarkListViewStream {
    struct Input: InputType {}

    struct Output: OutputType {
        let bookmarks: BehaviorRelay<[Repository]>
        let reloadData: PublishRelay<Void>
    }

    struct State: StateType {
        let bookmarks = BehaviorRelay<[Repository]>(value: [])
    }

    struct Extra: ExtraType {
        let flux: Flux
    }
}

extension BookmarkListViewStream {
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let state = dependency.state
        let extra = dependency.extra

        let flux = extra.flux

        let bookmarks = flux.repositoryStore.bookmarks.asObservable()

        bookmarks
            .bind(to: state.bookmarks)
            .disposed(by: disposeBag)

        let reloadData = PublishRelay<Void>()

        bookmarks
            .map(void)
            .bind(to: reloadData)
            .disposed(by: disposeBag)

        return Output(bookmarks: state.bookmarks,
                      reloadData: reloadData)
    }
}
