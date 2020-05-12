import RxRelay
import RxSwift

final class Property<Element> {

    public typealias E = Element

    private let _behaviorRelay: BehaviorRelay<E>

    public var value: E {
        get {
            return _behaviorRelay.value
        }
    }

    public init(_ value: E) {
        self._behaviorRelay = BehaviorRelay(value: value)
    }

    public init(_ behaviorRelay: BehaviorRelay<E>) {
        self._behaviorRelay = behaviorRelay
    }

    public func asObservable() -> Observable<E> {
        return _behaviorRelay.asObservable()
    }
}
