import RxSwift
import RxTest

@dynamicMemberLookup
public final class WatchStack<Element> {
    private let disposeBag = DisposeBag()
    private let observer: TestableObserver<Element>

    public init<O: ObservableType>(
        _ observable: O,
        scheduler: TestScheduler = .init(initialClock: 0)
    ) where Element == O.Element {
        observer = scheduler.createObserver(Element.self)
        observable.subscribe(observer).disposed(by: disposeBag)
    }

    /// `first` `last` `count` などのプロパティを `observer.events` にプロキシする
    /// - NOTE: `completed` や `error` は含まれない
    public subscript<T>(dynamicMember keyPath: KeyPath<[Element], T>) -> T {
        let elements = observer.events.compactMap { $0.value.element }
        return elements[keyPath: keyPath]
    }
}

extension WatchStack {
    /// - Returns: タイミング情報を持たないイベントの一覧
    public var events: [Event<Element>] {
        observer.events.map { $0.value }
    }

    /// - Returns: 最後の `next` の値
    /// - NOTE: `last` のエイリアス。
    ///         `completed` や `error` が流れていても、最後の `next` の値を返す。
    public var value: Element? { self.last }

    /// - Returns: `error` の値
    public var error: Error? {
        guard case let .error(error)? = observer.events.last?.value else {
            return nil
        }
        return error
    }
}
