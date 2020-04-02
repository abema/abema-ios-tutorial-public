import UIKit

final class BookmarkListViewDataSource: NSObject {

    private let viewStream: BookmarkListViewStreamType

    init(viewStream: BookmarkListViewStreamType) {
        self.viewStream = viewStream
    }
}

extension BookmarkListViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewStream.output.bookmarks.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookmarks = viewStream.output.bookmarks.value

        guard let repository = bookmarks[safe: indexPath.row] else {
            developmentFatalError("Index is out of bounds")
            return UITableViewCell()
        }

        guard let cell = tableView.dequeue(RepositoryListCell.self, for: indexPath) else {
            developmentFatalError("Index is out of bounds")
            return UITableViewCell()
        }

        cell.repository = repository

        return cell
    }
}
