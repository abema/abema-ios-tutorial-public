import Foundation
import RxSwift

// MARK: ObservableType where Element: OptionalType
// Observable<E>のEがOptionalだった場合
extension ObservableType where Element: OptionalType {

    /// Filters out the nil elements of a sequence of optional elements
    /// - returns: An observable sequence of only the non-nil elements
    public func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { item -> Observable<Element.Wrapped> in
            if let value = item.value {
                return Observable.just(value)
            } else {
                return Observable.empty()
            }
        }
    }
}
