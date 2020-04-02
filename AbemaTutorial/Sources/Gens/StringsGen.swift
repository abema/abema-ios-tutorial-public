// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
internal enum L10n {
  /// このレポジトリは既に登録されています。
  internal static let alreadyBookmarkedAlertMessage = L10n.tr("Localizable", "AlreadyBookmarkedAlertMessage")
  /// お気に入り
  internal static let alreadyBookmarkedAlertTitle = L10n.tr("Localizable", "AlreadyBookmarkedAlertTitle")
  /// 登録する
  internal static let bookmark = L10n.tr("Localizable", "Bookmark")
  /// お気に入りに登録しますか？
  internal static let bookmarkAlertMessage = L10n.tr("Localizable", "BookmarkAlertMessage")
  /// 閉じる
  internal static let close = L10n.tr("Localizable", "Close")
  /// エラーが発生しました。\nもう一度お試しください。
  internal static let fetchErrorAlertMessage = L10n.tr("Localizable", "FetchErrorAlertMessage")
  /// エラー
  internal static let fetchErrorAlertTitle = L10n.tr("Localizable", "FetchErrorAlertTitle")
  /// 削除する
  internal static let unbookmark = L10n.tr("Localizable", "Unbookmark")
  /// お気に入りから削除しますか？
  internal static let unbookmarkAlertMessage = L10n.tr("Localizable", "UnbookmarkAlertMessage")
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String) -> String {
    return NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
  }

  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
