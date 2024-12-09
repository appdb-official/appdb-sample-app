//
//  SceneDelegate.swift
//  TestAppdb
//
//  Created by Dmitrii Coolerov on 19.03.2024.
//

import AppdbSDK
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        guard let _scene = (scene as? UIWindowScene) else { return }

        UNUserNotificationCenter.current().delegate = self

        if let urlContext = connectionOptions.urlContexts.first {
            handleContext(urlContext: urlContext)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            handleContext(urlContext: urlContext)
        }
    }

    private func getRootVC() -> UIViewController? {
        let keyWindow: UIWindow? = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)

        return keyWindow?.rootViewController
    }

    private func deeplinkURLToDict(urlString: String) -> [String: String] {
        let path = urlString.components(separatedBy: "://").last!
        let args = path.components(separatedBy: "&")
        var argsDict = [String: String]()
        args.forEach { arg in
            let comps = arg.components(separatedBy: "=")
            let key = comps.first!
            let value = comps.last!
            argsDict[key] = value
        }
        return argsDict
    }

    private func handleContext(urlContext: UIOpenURLContext) {
        let sendingAppID = urlContext.options.sourceApplication ?? "Unknown"
        let url = urlContext.url

        // Pass only appdb deeplinks to sdk
        if let urlScheme = url.scheme, urlScheme.starts(with: "appdb.") {
            Appdb.shared.handleDeeplink(url)
        }

        let argsDict = deeplinkURLToDict(urlString: url.absoluteString)
        if argsDict.keys.contains("deeplink") {
            let deeplink = argsDict["deeplink"]?.removingPercentEncoding ?? "Unknown"

            let alertVC = UIAlertController(title: "deeplink", message: "(\(sendingAppID)) " + deeplink, preferredStyle: .alert)
            alertVC.addAction(.init(title: "OK", style: .default))

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self = self else { return }
                self.getRootVC()?.present(alertVC, animated: true)
            }
            return
        }
    }
}

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
