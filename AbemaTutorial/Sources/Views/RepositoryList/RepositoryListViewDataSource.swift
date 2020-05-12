import UIKit

final class RepositoryListViewDataSource: NSObject {

    private let viewStream: RepositoryListViewStreamType

    init(viewStream: RepositoryListViewStreamType) {
        self.viewStream = viewStream
    }
}

extension RepositoryListViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewStream.output.repositories.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repositories = viewStream.output.repositories.value

        guard let repository = repositories[safe: indexPath.row] else {
            developmentFatalError("Index is out of bounds")
            return UITableViewCell()
        }

        guard let cell = tableView.dequeue(RepositoryListCell.self, for: indexPath) else {
            developmentFatalError("Cell is not registered")
            return UITableViewCell()
        }

        cell.repository = repository

        return cell
    }
}
