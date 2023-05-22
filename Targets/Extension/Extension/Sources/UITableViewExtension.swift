import UIKit

public extension UITableView {
    func register<Cell: UITableViewCell>(_ cellType: Cell.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeue<Cell: UITableViewCell>(_ cellType: Cell.Type, for indexPath: IndexPath) -> Cell? {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? Cell else {
            return nil
        }
        return cell
    }
}

public extension UITableViewCell {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
