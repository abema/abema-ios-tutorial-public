import RxRelay
import RxSwift
import Unio
import UseCaseInterface

/// @mockable
public protocol RepositoryListViewStreamType: AnyObject {
    var input: InputWrapper<RepositoryListViewStreamInput> { get }
    var output: OutputWrapper<RepositoryListViewStreamOutput> { get }
}

public struct RepositoryListViewStreamInput: InputType {
    public let viewWillAppear = PublishRelay<Void>()
    public let refreshControlValueChanged = PublishRelay<Void>()

    public init() {}
}

public struct RepositoryListViewStreamOutput: OutputType {
    public let titles: BehaviorRelay<[String]>
    public let reloadData: PublishRelay<Void>
    public let isRefreshControlRefreshing: BehaviorRelay<Bool>

    public init(
        titles: BehaviorRelay<[String]>,
        reloadData: PublishRelay<Void>,
        isRefreshControlRefreshing: BehaviorRelay<Bool>
    ) {
        self.titles = titles
        self.reloadData = reloadData
        self.isRefreshControlRefreshing = isRefreshControlRefreshing
    }
}
