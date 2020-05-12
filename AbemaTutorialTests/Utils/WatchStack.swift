import RxSwift
import RxTest

struct WatchStack<Element> {
    let scheduler: TestScheduler
    let observer: TestableObserver<Element>
    let disposeBag = DisposeBag()

    init<O: ObservableType>(_ observable: O,
                            scheduler: TestScheduler = .init(initialClock: 0))
    where O.Element == Element {
        self.scheduler = scheduler
        self.observer = scheduler.createObserver(Element.self)
        observable
            .subscribe(observer)
            .disposed(by: disposeBag)
    }

    var events: [Event<Element>] {
        return observer.events.map { $0.value }
    }

    var event: Event<Element>? {
        return observer.events.last.flatMap { $0.value }
    }

    var values: [Element] {
        return events.compactMap { $0.element }
    }

    var value: Element? {
        return event?.element
    }
}
