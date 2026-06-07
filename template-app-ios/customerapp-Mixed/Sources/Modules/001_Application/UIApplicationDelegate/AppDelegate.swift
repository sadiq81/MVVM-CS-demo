import UIKit

//import FirebaseCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // DI Container
        AppContainer.configure()

        // Firebase
//        FirebaseApp.configure()

        // Appearance
        Appearance.configure()

        // App setup
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.coordinator = AppCoordinator(window: self.window!)
        try? self.coordinator?.start()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return false
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }

}
