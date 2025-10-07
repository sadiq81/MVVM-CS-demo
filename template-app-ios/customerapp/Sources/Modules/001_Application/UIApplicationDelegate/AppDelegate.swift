import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinatorType?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Firebase
        FirebaseApp.configure()

        // Appearance
        Appearance.configure()

        // App setup
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.coordinator = AppCoordinator(window: window!)
        try? self.coordinator?.start()

        self.coordinator?.didFinishLaunchingWith(application: application, options: launchOptions)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return self.coordinator?.application(app, open: url, options: options) ?? false
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.coordinator?.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

}
