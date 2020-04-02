import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = {
            let window = UIWindow()

            let repositoryListViewController = RepositoryListViewController()
            repositoryListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 0)

            let bookmarkListViewController = BookmarkListViewController()
            bookmarkListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

            let mainTabViewController = UITabBarController()
            mainTabViewController.viewControllers = [repositoryListViewController,
                                                     bookmarkListViewController]

            window.rootViewController = mainTabViewController
            window.makeKeyAndVisible()

            return window
        }()
        return true
    }
}
