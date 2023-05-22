#if ENABLE_PREVIEW
import SwiftUI
import UIKit
import UILogicInterface

@available(iOS 13.0, *)
enum RepositoryListViewController_Preview: PreviewProvider {

    // RunするまでStatus Barが表示されずTableViewが意図する位置にいないが、一旦許容する
    public static let previews = PreviewGroup.viewController {
        Preview {
            let titles = [
                "owner1 / name1",
                "owner2 / name2",
            ]

            let input = RepositoryListViewStreamInput()

            let output = RepositoryListViewStreamOutput(
                titles: .init(value: titles),
                reloadData: .init(),
                isRefreshControlRefreshing: .init(value: false)
            )

            let vs = RepositoryListViewStreamTypeMock(
                input: .init(input),
                output: .init(output)
            )
            let vc = RepositoryListViewController(viewStream: vs)

            return vc
        }
    }
    .previewSize(width: .full, height: .full)
}
#endif
