import UIKit
import SwiftUI
import RxSwift

#if ENABLE_PREVIEW

// MARK: - Preview Group

@available(iOS 13.0, *)
public protocol PreviewProvider: SwiftUI.PreviewProvider {
    static var previews: AnyPreviewGroup { get }
}

public protocol _Previewable {}
extension UIView: _Previewable {}
extension UIViewController: _Previewable {}

public enum AnyPreviewGroup {
    case view(PreviewGroup<UIView>)
    case viewController(PreviewGroup<UIViewController>)

    public var name: String {
        switch self {
        case let .view(group): return group.name
        case let .viewController(group): return group.name
        }
    }
}

public struct PreviewGroup<T: _Previewable> {
    public let name: String

    public fileprivate(set) var previews: [Preview<T>]
    public fileprivate(set) var width: PreviewSize = .intrinsic
    public fileprivate(set) var height: PreviewSize = .intrinsic
    public fileprivate(set) var backgroundColor: UIColor = .darkCheckPattern
    public fileprivate(set) var device: PreviewDevice = .iPhone_X
}

extension PreviewGroup where T == UIView {

    public static func view(
        name: String? = nil,
        file: String = #file,
        @PreviewGroupBuilder builder: () -> [Preview<UIView>]
    ) -> AnyPreviewGroup {
        return .view(self.init(name: name ?? Self.defaultName(file), previews: builder()))
    }
}

extension PreviewGroup where T == UIViewController {

    public static func viewController(
        name: String? = nil,
        file: String = #file,
        @PreviewGroupBuilder builder: () -> [Preview<UIViewController>]
    ) -> AnyPreviewGroup {
        return .viewController(self.init(name: name ?? Self.defaultName(file), previews: builder()))
    }
}

extension PreviewGroup {
    private static func defaultName(_ file: String) -> String {
        var fileName = URL(string: file)?.lastPathComponent ?? file
        let suffix = "_Preview.swift"
        if fileName.hasSuffix(suffix) {
            fileName.removeLast(suffix.count)
        }
        return fileName
    }
}

@available(iOS 13.0, *)
extension AnyPreviewGroup: View {
    public var body: AnyView {
        switch self {
        case let .view(group):
            return AnyView(ForEach(group.previews, id: \.name) { preview in
                preview.makeView(group: group)
                    .previewDisplayName(preview.name)
                    .previewDevice((preview.device ?? group.device)?.swiftUI)
            })
        case let .viewController(group):
            return AnyView(ForEach(group.previews, id: \.name) { preview in
                preview.makeView(group: group)
                    .previewDisplayName(preview.name)
                    .previewDevice((preview.device ?? group.device)?.swiftUI)
            })
        }
    }
}

@resultBuilder
public enum PreviewGroupBuilder {
    public static func buildBlock<T: _Previewable>(_ previews: Preview<T>...) -> [Preview<T>] { previews }
}

// MARK: - Preview

public struct Preview<T: _Previewable> {
    public let name: String
    public let factory: () -> T

    // nilのときPreviewGroupの指定にフォールバック
    public fileprivate(set) var width: PreviewSize?
    public fileprivate(set) var height: PreviewSize?
    public fileprivate(set) var backgroundColor: UIColor?
    public fileprivate(set) var device: PreviewDevice?
}

// WORKAROUND: UIViewとUIViewControllerそれぞれで定義しないと推論ができない
// (`where T: _Previewable` 指定だと `Preview("name") { ... }` が ambiguous になる)

extension Preview where T == UIView {
    public init(_ name: String = "Default", factory: @escaping () -> T) {
        self.name = name
        self.factory = factory
    }
}

extension Preview where T == UIViewController {
    public init(_ name: String = "Default", factory: @escaping () -> T) {
        self.name = name
        self.factory = factory
    }
}

// MARK: - SwiftUI

@available(iOS 13.0, *)
fileprivate extension Preview where T: UIView {
    struct SwiftUIView: View, UIViewRepresentable {
        let preview: Preview
        let group: PreviewGroup<UIView>

        func makeUIView(context: Context) -> UIView { UIView() }

        func updateUIView(_ containerView: UIView, context: Context) {
            let previewView = preview.factory()
            previewView.translatesAutoresizingMaskIntoConstraints = false

            containerView.backgroundColor = (preview.backgroundColor ?? group.backgroundColor)
            containerView.addSubview(previewView)

            NSLayoutConstraint.activate([
                previewView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                previewView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                (preview.width ?? group.width).makeConstraint(
                    viewAnchor: previewView.widthAnchor,
                    containerViewAnchor: containerView.widthAnchor
                ),
                (preview.height ?? group.height).makeConstraint(
                    viewAnchor: previewView.heightAnchor,
                    containerViewAnchor: containerView.heightAnchor
                ),
            ].compactMap { $0 })
        }
    }

    func makeView(group: PreviewGroup<UIView>) -> SwiftUIView {
        SwiftUIView(preview: self, group: group)
    }
}

@available(iOS 13.0, *)
fileprivate extension Preview where T: UIViewController {
    struct SwiftUIViewController: View, UIViewControllerRepresentable {
        let preview: Preview
        let group: PreviewGroup<UIViewController>

        func makeUIViewController(context: Context) -> UIViewController {
            preview.factory()
        }

        func updateUIViewController(_: UIViewController, context: Context) {}
    }

    func makeView(group: PreviewGroup<UIViewController>) -> SwiftUIViewController {
        SwiftUIViewController(preview: self, group: group)
    }
}

// MARK: - Preview Configuration

public enum PreviewSize {
    // 固定のサイズ (pt)
    case constant(CGFloat)

    // 親ビューのサイズに対する割合
    case multiplier(CGFloat)

    // Auto Layoutに従ったサイズ (制約を作らない)
    case intrinsic

    // 親ビューと一致させる
    public static var full: Self { .multiplier(1) }

    public func makeConstraint(viewAnchor: NSLayoutDimension,
                        containerViewAnchor: NSLayoutDimension) -> NSLayoutConstraint? {
        switch self {
        case .constant(let constant):
            return viewAnchor.constraint(equalToConstant: constant)
        case .multiplier(let multiplier):
            return viewAnchor.constraint(equalTo: containerViewAnchor, multiplier: multiplier)
        case .intrinsic:
            return nil
        }
    }
}

extension Preview {
    func previewWidth(_ size: PreviewSize) -> Self {
        var preview = self
        preview.width = size
        return preview
    }

    func previewHeight(_ size: PreviewSize) -> Self {
        var preview = self
        preview.height = size
        return preview
    }

    func previewSize(width: PreviewSize, height: PreviewSize) -> Self {
        return self.previewWidth(width).previewHeight(height)
    }

    func previewBackground(_ color: UIColor) -> Self {
        var preview = self
        preview.backgroundColor = color
        return preview
    }

    func previewDevice(_ device: PreviewDevice?) -> Self {
        var preview = self
        preview.device = device
        return preview
    }
}

extension AnyPreviewGroup {
    func previewWidth(_ size: PreviewSize) -> Self {
        switch self {
        case var .view(group):
            group.width = size
            return .view(group)
        case var .viewController(group):
            group.width = size
            return .viewController(group)
        }
    }

    func previewHeight(_ size: PreviewSize) -> Self {
        switch self {
        case var .view(group):
            group.height = size
            return .view(group)
        case var .viewController(group):
            group.height = size
            return .viewController(group)
        }
    }

    func previewSize(width: PreviewSize, height: PreviewSize) -> Self {
        return self.previewWidth(width).previewHeight(height)
    }

    func previewBackground(_ color: UIColor) -> Self {
        switch self {
        case var .view(group):
            group.backgroundColor = color
            return .view(group)
        case var .viewController(group):
            group.backgroundColor = color
            return .viewController(group)
        }
    }

    func previewDevice(_ device: PreviewDevice) -> Self {
        switch self {
        case var .view(group):
            group.device = device
            return .view(group)
        case var .viewController(group):
            group.device = device
            return .viewController(group)
        }
    }
}

// MARK: Preview Device

/// - seealso: https://developer.apple.com/documentation/swiftui/securefield/3289399-previewdevice
public enum PreviewDevice: String {
    case iPhone_7 = "iPhone 7"
    case iPhone_7_Plus = "iPhone 7 Plus"
    case iPhone_8 = "iPhone 8"
    case iPhone_8_Plus = "iPhone 8 Plus"
    case iPhone_SE = "iPhone SE"
    case iPhone_X = "iPhone X"
    case iPhone_Xs = "iPhone Xs"
    case iPhone_Xs_Max = "iPhone Xs Max"
    case iPhone_XR = "iPhone Xʀ"
    case iPad_mini_4 = "iPad mini 4"
    case iPad_Air_2 = "iPad Air 2"
    case iPad_Pro_9_7 = "iPad Pro (9.7-inch)"
    case iPad_Pro_12_9 = "iPad Pro (12.9-inch)"
    case iPad_5G = "iPad (5th generation)"
    case iPad_Pro_12_9_2G = "iPad Pro (12.9-inch) (2nd generation)"
    case iPad_Pro_10_5 = "iPad Pro (10.5-inch)"
    case iPad_6G = "iPad (6th generation)"
    case iPad_Pro_11 = "iPad Pro (11-inch)"
    case iPad_Pro_12_9_3G = "iPad Pro (12.9-inch) (3rd generation)"
    case iPad_mini_5G = "iPad mini (5th generation)"
    case iPad_Air_3G = "iPad Air (3rd generation)"

    @available(iOS 13.0, *)
    var swiftUI: SwiftUI.PreviewDevice {
        .init(rawValue: rawValue)
    }
}

// MARK: - Utility Extentions

extension UIColor {
    private static func makeCheckPattern(size: CGFloat = 20, base: CGFloat, delta: CGFloat) -> UIColor {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            context.cgContext.setFillColor(gray: base, alpha: 1.0)
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))

            context.cgContext.setFillColor(gray: base + delta, alpha: 1.0)
            context.fill(CGRect(x: 0, y: 0, width: size / 2, height: size / 2))
            context.fill(CGRect(x: size / 2, y: size / 2, width: size / 2, height: size / 2))
        }
        return UIColor(patternImage: image)
    }

    static var lightCheckPattern = makeCheckPattern(base: 1, delta: -0.05)
    static var darkCheckPattern = makeCheckPattern(base: 0, delta: 0.05)
}

extension NSObject {
    static func loadImage(named name: String, to imageView: UIImageView) -> Disposable {
        let image = UIImage(named: name, in: Bundle(for: self), compatibleWith: nil)
        imageView.image = image
        return Disposables.create()
    }
}

#endif
