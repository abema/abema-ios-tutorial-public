import Foundation
import RxSwift
import RxRelay

/// @PublishWrapper()
/// private(set) var count: Observable<Int>
/// _count.accept(1) // <- アンダースコアでacceptにアクセス可能
public typealias PublishWrapper<T> = RelayWrapper<Observable<T>, T>

/// @BehaviorWrapper(value: 0)
/// private(set) var count: Property<Int>
/// _count.accept(1) // <- アンダースコアでacceptにアクセス可能
public typealias BehaviorWrapper<T> = RelayWrapper<Property<T>, T>

@propertyWrapper
public struct RelayWrapper<Wrapped, Element> {

    public let wrappedValue: Wrapped

    /// 宣言した型内でしかアクセスできない値を更新するためのclosure
    public let accept: (Element) -> Void

    private init(wrapped: Wrapped, accept: @escaping (Element) -> Void) {
        self.wrappedValue = wrapped
        self.accept = accept
    }
}

public extension RelayWrapper where Wrapped == Observable<Element> {
    init() {
        let relay = PublishRelay<Element>()
        self.init(wrapped: relay.asObservable(), accept: { relay.accept($0) })
    }
}

public extension RelayWrapper where Wrapped == Property<Element> {
    init(value: Element) {
        let relay = BehaviorRelay(value: value)
        self.init(wrapped: Property(relay), accept: { relay.accept($0) })
    }
}

/// - seealso: https://github.com/ReactiveX/RxSwift/blob/5.0.1/RxRelay/Observable+Bind.swift
public extension ObservableType {

    func bind<Wrapped>(to relays: RelayWrapper<Wrapped, Element>...) -> Disposable {
        self.bind(to: relays)
    }

    func bind<Wrapped>(to relays: RelayWrapper<Wrapped, Element?>...) -> Disposable {
        self.map { $0 as Element? }.bind(to: relays)
    }

    private func bind<Wrapped>(to relays: [RelayWrapper<Wrapped, Element>]) -> Disposable {
        self.subscribe { e in
            switch e {
            case let .next(element):
                relays.forEach {
                    $0.accept(element)
                }
            case let .error(error):
                developmentFatalError("Binding error to RelayWrapper: \(error)")
            case .completed:
                break
            }
        }
    }
}
