import Extension
import UILogicInterface
import UIKit

final class RepositoryListViewDataSource: NSObject {

    private let viewStream: RepositoryListViewStreamType

    init(viewStream: RepositoryListViewStreamType) {
        self.viewStream = viewStream
    }
}

extension RepositoryListViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewStream.output.titles.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titles = viewStream.output.titles.value

        guard let title = titles[safe: indexPath.row] else {
            developmentFatalError("Index is out of bounds")
            return UITableViewCell()
        }

        guard let cell = tableView.dequeue(RepositoryListCell.self, for: indexPath) else {
            developmentFatalError("Cell is not registered")
            return UITableViewCell()
        }

        cell.configure(title: title)

        return cell
    }
}
