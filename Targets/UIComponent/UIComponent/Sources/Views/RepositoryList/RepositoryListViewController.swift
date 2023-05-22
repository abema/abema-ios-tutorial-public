import RxCocoa
import RxSwift
import UIKit
import UILogicInterface

public final class RepositoryListViewController: UIViewController {

    private let viewStream: RepositoryListViewStreamType

    private lazy var dataSource = RepositoryListViewDataSource(viewStream: viewStream)

    private let disposeBag = DisposeBag()

    // MARK: UI

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = dataSource
        tableView.refreshControl = refreshControl
        tableView.register(RepositoryListCell.self)
        tableView.register(UITableViewCell.self) // フォールバック用
        return tableView
    }()

    private let refreshControl = UIRefreshControl()

    public init(viewStream: RepositoryListViewStreamType) {
        self.viewStream = viewStream

        super.init(nibName: nil, bundle: nil)

        // Layout
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Bind
        viewStream.output.reloadData
            .bind(to: Binder(tableView) { tableView, _ in
                tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewStream.output.isRefreshControlRefreshing
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewStream.input.refreshControlValueChanged)
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewStream.input.viewWillAppear(())
    }
}
