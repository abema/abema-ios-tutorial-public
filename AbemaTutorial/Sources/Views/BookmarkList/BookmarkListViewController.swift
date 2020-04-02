import UIKit
import RxCocoa
import RxSwift

final class BookmarkListViewController: UIViewController {

    private let viewStream = BookmarkListViewStream()

    private lazy var dataSource = BookmarkListViewDataSource(viewStream: viewStream)

    private let disposeBag = DisposeBag()

    // MARK: UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = dataSource
        tableView.register(RepositoryListCell.self)
        tableView.register(UITableViewCell.self)
        return tableView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        // Bind
        viewStream.output.reloadData
            .bind(to: Binder(tableView) { tableView, _ in
                tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
