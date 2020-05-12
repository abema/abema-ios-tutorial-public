import RxRelay
import RxSwift
import UIKit

class DispatchRelay<Element> {
    private let relay = PublishRelay<Element>()

    func dispatch(_ element: Element) {
        relay.accept(element)
    }
}

extension DispatchRelay: ObservableType {
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable
        where Element == Observer.Element {
        return relay.subscribe(observer)
    }
}
