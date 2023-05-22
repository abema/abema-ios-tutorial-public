import TestExtension
import RxSwift
import RxTest
import XCTest

class WatchStackTests: XCTestCase {
    func test_PublishSubject_empty() {
        let subject = PublishSubject<Int>()
        let stack = WatchStack(subject)
        XCTAssertEqual(stack.count, 0)
        XCTAssertEqual(stack.value, nil)
        XCTAssertNil(stack.error)
    }

    func test_PublishSubject_single_event() {
        let subject = PublishSubject<Int>()
        let stack = WatchStack(subject)

        subject.onNext(100)

        XCTAssertEqual(stack.count, 1)
        XCTAssertEqual(stack.value, 100)
        XCTAssertNil(stack.error)
    }

    func test_PublishSubject_multiple_event() {
        let subject = PublishSubject<Int>()
        let stack = WatchStack(subject)

        subject.onNext(100)
        subject.onNext(200)
        subject.onNext(300)

        XCTAssertEqual(stack.count, 3)
        XCTAssertEqual(stack.first, 100)
        XCTAssertEqual(stack.last, 300)
        XCTAssertEqual(stack.value, 300)
        XCTAssertNil(stack.error)
    }

    func test_PublishSubject_error() {
        let subject = PublishSubject<Int>()
        let stack = WatchStack(subject)

        subject.onNext(100)
        subject.onNext(200)
        subject.onNext(300)
        subject.onError(RxError.timeout)

        XCTAssertEqual(stack.count, 3)
        XCTAssertEqual(stack.first, 100)
        XCTAssertEqual(stack.last, 300)
        XCTAssertEqual(stack.value, 300)
        XCTAssertNotNil(stack.error)
    }

    func test_PublishSubject_async_event() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let subject = PublishSubject<Int>()
        let stack = WatchStack(subject, scheduler: scheduler)

        Observable<Int>
            .just(123)
            .delay(.seconds(10), scheduler: scheduler)
            .subscribe(subject)
            .disposed(by: disposeBag)

        scheduler.advanceTo(20)

        XCTAssertEqual(stack.count, 1)
        XCTAssertEqual(stack.value, 123)
        XCTAssertNil(stack.error)
    }
}
