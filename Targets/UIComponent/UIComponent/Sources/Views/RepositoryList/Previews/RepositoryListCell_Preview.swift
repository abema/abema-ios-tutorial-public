#if ENABLE_PREVIEW
import SwiftUI

@available(iOS 13.0, *)
enum VideoRankingCellView_Preview: PreviewProvider {

    public static let previews = PreviewGroup.view {
        Preview("RepositoryListCell") {
            let view = RepositoryListCell()
            view.configure(title: "owner / name")
            view.backgroundColor = .white
            return view
        }
    }
    .previewWidth(.full)
    .previewHeight(.constant(44))
}
#endif
