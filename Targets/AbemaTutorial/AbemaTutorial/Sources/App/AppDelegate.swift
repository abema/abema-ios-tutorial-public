import UIKit
import Repository
import UIComponent
import UILogic
import UseCase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = {
            let window = UIWindow()
            window.rootViewController = RepositoryListViewController(
                viewStream: RepositoryListViewStream(
                    repositoryListUseCase: RepositoryListUseCase(
                        repositoryRepository: RepositoryRepository()
                    )
                )
            )
            window.makeKeyAndVisible()
            return window
        }()
        return true
    }
}
