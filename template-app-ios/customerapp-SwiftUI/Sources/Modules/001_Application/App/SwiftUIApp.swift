
import SwiftUI
import UIKit

import MustacheServices

@main
struct CustomerApp: App {

    init() {
        // DI Container
        AppContainer.configure()

        // Custom fonts — swizzle UIFont.preferredFont to use Montserrat
        Appearance.configure()

        // Firebase
//        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
