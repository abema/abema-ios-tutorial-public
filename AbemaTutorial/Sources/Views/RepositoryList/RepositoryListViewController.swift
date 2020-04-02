import UIKit
import RxCocoa
import RxSwift

final class RepositoryListViewController: UIViewController {

    private let viewStream = RepositoryListViewStream()

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

    init() {
        super.init(nibName: nil, bundle: nil)

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
            .bind(to: viewStream.input.accept(for: \.refreshControlValueChanged))
            .disposed(by: disposeBag)

        viewStream.output.presentFetchErrorAlert
            .bind(to: Binder(self) { me, _ in
                me.presentFetchErrorAlert()
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .bind(to: viewStream.input.accept(for: \.didSelectCell))
            .disposed(by: disposeBag)

        viewStream.output.presentBookmarkAlert
            .bind(to: Binder(self) { me, args in
                let (indexPath, repository) = args
                me.presentBookmarkAlert(indexPath: indexPath, repository: repository)
            })
            .disposed(by: disposeBag)

        viewStream.output.presentUnbookmarkAlert
            .bind(to: Binder(self) { me, args in
                let (indexPath, repository) = args
                me.presentUnbookmarkAlert(indexPath: indexPath, repository: repository)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewStream.input.viewDidAppear(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewStream.input.viewWillAppear(())
    }

    private func presentFetchErrorAlert() {
        let alertController = UIAlertController(title: L10n.fetchErrorAlertTitle,
                                                message: L10n.fetchErrorAlertMessage,
                                                preferredStyle: .alert)

        let closeAction = UIAlertAction(title: L10n.close, style: .cancel) { [weak self] _ in
            self?.viewStream.input.fetchErrorAlertDismissed(())
        }

        alertController.addAction(closeAction)
        present(alertController, animated: true)
    }

    private func presentBookmarkAlert(indexPath: IndexPath, repository: Repository) {
        let alertController = UIAlertController(title: repository.name,
                                                message: L10n.bookmarkAlertMessage,
                                                preferredStyle: .alert)

        let closeAction = UIAlertAction(title: L10n.close, style: .cancel) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: false)
            self?.viewStream.input.fetchErrorAlertDismissed(())
        }
        alertController.addAction(closeAction)

        let bookmarkAction = UIAlertAction(title: L10n.bookmark, style: .default) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: false)
            self?.viewStream.input.didBookmarkRepository(repository)
        }
        alertController.addAction(bookmarkAction)

        present(alertController, animated: true)
    }

    private func presentUnbookmarkAlert(indexPath: IndexPath, repository: Repository) {
        let alertController = UIAlertController(title: repository.name,
                                                message: L10n.unbookmarkAlertMessage,
                                                preferredStyle: .alert)

        let closeAction = UIAlertAction(title: L10n.close, style: .cancel) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: false)
            self?.viewStream.input.fetchErrorAlertDismissed(())
        }
        alertController.addAction(closeAction)

        let unbookmarkAction = UIAlertAction(title: L10n.unbookmark, style: .default) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: false)
            self?.viewStream.input.didUnbookmarkRepository(repository)
        }
        alertController.addAction(unbookmarkAction)

        present(alertController, animated: true)
    }
}
