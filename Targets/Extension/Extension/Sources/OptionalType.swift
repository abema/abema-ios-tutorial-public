/// Protocol type for Optionals.
/// Used for extensions to protocols with associated types.
/// Can restrict the extension to only when the associated tye is Optional
public protocol OptionalType {
    associatedtype Wrapped

    static var none: Self { get }
    static func some(_ wrapped: Wrapped) -> Self
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? { return self }
}
