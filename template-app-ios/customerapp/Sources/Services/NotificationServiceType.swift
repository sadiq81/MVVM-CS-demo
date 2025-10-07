import Foundation
import UIKit

import MustacheServices
import UserNotifications
import FirebaseMessaging

protocol NotificationServiceType {

    func received(deviceToken: Data)

    func register()

}

class NotificationService: NSObject, NotificationServiceType {

    @Injected
    private var installationService: InstallationServiceType
    
    @LazyInjected
    private var networkService: AsyncNetworkServiceType

    override init() {
        super.init()
        self.configure()
    }

    private func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func register() { Task {

        let settings: UNNotificationSettings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
            case .notDetermined:
                let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                if result { fallthrough } else { return }
            case .authorized:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied, .ephemeral, .provisional:
                return
            @unknown default:
                return
        }

    }}

    func received(deviceToken: Data) {

        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        debugPrint("deviceToken: \(token)")

        Messaging.messaging().apnsToken = deviceToken

        /// We clear the token when logging out, but when a new user logs in the fcmtoken will not updated and we will not call the middleware with the new users token
        if let fcmToken = Messaging.messaging().fcmToken {
            self.messaging(Messaging.messaging(), didReceiveRegistrationToken: fcmToken)
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

extension NotificationService: UNUserNotificationCenterDelegate {

    // Called when app is running in foreground to determine if push notification is shown
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler([.badge, .sound, .banner])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler()
    }

}

extension NotificationService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) { Task {
        let appInstallationId = try await self.installationService.appInstallationId()
        let request = FCMTokenRequest(token: fcmToken, installationId: appInstallationId)
        try await self.networkService.update(request: request)
    }}

}
